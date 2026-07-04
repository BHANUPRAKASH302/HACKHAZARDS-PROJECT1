import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_service.dart';

class PrescriptoService {
  PrescriptoService._();
  static final PrescriptoService instance = PrescriptoService._();

  String? lastError;

  /// True when the last fetch failed specifically because the JWT is
  /// expired / invalid (401 or 403 from the backend).
  bool isSessionExpired = false;

  Future<Map<String, String>?> _headers() async {
    final token = await AuthService.instance.getToken();
    if (token == null) return null;
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // Local fallback storage for bookings
  final List<Map<String, dynamic>> _localBookings = [];

  Future<List<Map<String, dynamic>>> getDoctors() async {
    lastError = null;
    try {
      final baseUrl = await AuthService.instance.getActiveBackendUrl();
      final response = await http
          .get(Uri.parse('$baseUrl/api/prescripto/doctors'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
      throw Exception('Failed to load doctors: ${response.statusCode}');
    } catch (e) {
      debugPrint('PrescriptoService.getDoctors error: $e');
      lastError = e.toString();
      return _mockDoctorsLocal();
    }
  }

  Future<List<Map<String, dynamic>>> getBookings() async {
    lastError = null;
    isSessionExpired = false;

    final headers = await _headers();
    if (headers == null) {
      lastError = 'Authentication required. Please log in again.';
      isSessionExpired = true;
      debugPrint('PrescriptoService.getBookings: no auth token');
      return List.from(_localBookings);
    }

    // Try each candidate backend URL in order
    final candidateUrls = await _candidateBackendUrls();
    debugPrint('PrescriptoService.getBookings: trying ${candidateUrls.length} URL(s): $candidateUrls');

    for (final baseUrl in candidateUrls) {
      try {
        final response = await http
            .get(Uri.parse('$baseUrl/api/prescripto/bookings'), headers: headers)
            .timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          final remoteBookings = List<Map<String, dynamic>>.from(data);
          debugPrint('PrescriptoService.getBookings: ✅ fetched ${remoteBookings.length} from $baseUrl');

          // Merge: add any local-only bookings not yet synced
          final remoteIds = remoteBookings.map((b) => b['_id']?.toString()).toSet();
          final localOnly = _localBookings
              .where((b) => !remoteIds.contains(b['_id']?.toString()))
              .toList();

          if (localOnly.isNotEmpty) {
            debugPrint('PrescriptoService.getBookings: merging ${localOnly.length} local-only booking(s)');
          }

          lastError = null;
          isSessionExpired = false;
          return [...localOnly, ...remoteBookings];
        }

        // 401/403 → session expired — clear the stale token and stop retrying
        if (response.statusCode == 401 || response.statusCode == 403) {
          Map<String, dynamic> body = {};
          try {
            body = jsonDecode(response.body) as Map<String, dynamic>;
          } catch (_) {}
          lastError = body['error']?.toString() ?? 'Session expired. Please log in again.';
          isSessionExpired = true;
          debugPrint('PrescriptoService.getBookings: 🔐 session expired from $baseUrl — $lastError');

          // Clear the stale token so the app forces re-login
          await AuthService.instance.saveToken('');
          break;
        }

        debugPrint('PrescriptoService.getBookings: $baseUrl returned ${response.statusCode}');
      } catch (e) {
        debugPrint('PrescriptoService.getBookings: $baseUrl unreachable — $e');
        lastError = e.toString();
      }
    }

    debugPrint('PrescriptoService.getBookings: ⚠️ returning ${_localBookings.length} local booking(s). sessionExpired=$isSessionExpired');
    return List.from(_localBookings);
  }

  /// Returns candidate base URLs to try, prioritising the last known-good one.
  Future<List<String>> _candidateBackendUrls() async {
    final active = await AuthService.instance.getActiveBackendUrl();
    final all = ApiConfig.candidateBaseUrls;
    final result = <String>[active];
    for (final url in all) {
      if (url != active) result.add(url);
    }
    return result;
  }

  Future<Map<String, dynamic>?> createBooking(Map<String, dynamic> bookingData) async {
    lastError = null;
    isSessionExpired = false;
    final headers = await _headers();
    if (headers == null) throw Exception('Authentication required.');

    final candidateUrls = await _candidateBackendUrls();

    for (final baseUrl in candidateUrls) {
      try {
        final response = await http
            .post(
              Uri.parse('$baseUrl/api/prescripto/bookings'),
              headers: headers,
              body: jsonEncode(bookingData),
            )
            .timeout(const Duration(seconds: 6));

        if (response.statusCode == 201 || response.statusCode == 200) {
          final created = jsonDecode(response.body) as Map<String, dynamic>;
          debugPrint('PrescriptoService.createBooking: ✅ saved to backend via $baseUrl');
          return created;
        }
        final errData = jsonDecode(response.body);
        throw Exception(errData['error'] ?? 'Booking failed (${response.statusCode})');
      } catch (e) {
        if (e is Exception && e.toString().contains('Booking failed')) rethrow;
        debugPrint('PrescriptoService.createBooking: $baseUrl failed — $e');
        lastError = e.toString();
      }
    }

    // All backends unreachable — store locally as fallback
    debugPrint('PrescriptoService.createBooking: ⚠️ storing booking locally (backend unreachable)');
    lastError = null;
    final newBooking = {
      '_id': 'local_${DateTime.now().millisecondsSinceEpoch}',
      'status': 'Pending',
      'createdAt': DateTime.now().toIso8601String(),
      ...bookingData
    };
    _localBookings.insert(0, newBooking);
    return newBooking;
  }

  Future<Map<String, dynamic>?> confirmBooking(String bookingId) async {
    lastError = null;
    try {
      final headers = await _headers();
      if (headers == null || bookingId.startsWith('local_')) {
        final idx = _localBookings.indexWhere((b) => b['_id'] == bookingId);
        if (idx != -1) {
          _localBookings[idx]['status'] = 'Completed';
          return _localBookings[idx];
        }
        return null;
      }

      final baseUrl = await AuthService.instance.getActiveBackendUrl();
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/prescripto/bookings/$bookingId/confirm'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      final errData = jsonDecode(response.body);
      throw Exception(errData['error'] ?? 'Failed to confirm booking');
    } catch (e) {
      debugPrint('PrescriptoService.confirmBooking error: $e');
      lastError = e.toString();
      final idx = _localBookings.indexWhere((b) => b['_id'] == bookingId);
      if (idx != -1) {
        _localBookings[idx]['status'] = 'Completed';
        return _localBookings[idx];
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> cancelBooking(String bookingId) async {
    lastError = null;
    try {
      final headers = await _headers();
      if (headers == null || bookingId.startsWith('local_')) {
        final idx = _localBookings.indexWhere((b) => b['_id'] == bookingId);
        if (idx != -1) {
          _localBookings[idx]['status'] = 'Cancelled';
          return _localBookings[idx];
        }
        return null;
      }

      final baseUrl = await AuthService.instance.getActiveBackendUrl();
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/prescripto/bookings/$bookingId/cancel'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      final errData = jsonDecode(response.body);
      throw Exception(errData['error'] ?? 'Failed to cancel booking');
    } catch (e) {
      debugPrint('PrescriptoService.cancelBooking error: $e');
      lastError = e.toString();
      final idx = _localBookings.indexWhere((b) => b['_id'] == bookingId);
      if (idx != -1) {
        _localBookings[idx]['status'] = 'Cancelled';
        return _localBookings[idx];
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> rescheduleBooking(String bookingId, DateTime newDate) async {
    lastError = null;
    try {
      final headers = await _headers();
      if (headers == null || bookingId.startsWith('local_')) {
        final idx = _localBookings.indexWhere((b) => b['_id'] == bookingId);
        if (idx != -1) {
          _localBookings[idx]['appointmentDate'] = newDate.toIso8601String();
          return _localBookings[idx];
        }
        return null;
      }

      final baseUrl = await AuthService.instance.getActiveBackendUrl();
      final response = await http
          .put(
            Uri.parse('$baseUrl/api/prescripto/bookings/$bookingId/reschedule'),
            headers: headers,
            body: jsonEncode({'appointmentDate': newDate.toIso8601String()}),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      final errData = jsonDecode(response.body);
      throw Exception(errData['error'] ?? 'Failed to reschedule booking');
    } catch (e) {
      debugPrint('PrescriptoService.rescheduleBooking error: $e');
      lastError = e.toString();
      final idx = _localBookings.indexWhere((b) => b['_id'] == bookingId);
      if (idx != -1) {
        _localBookings[idx]['appointmentDate'] = newDate.toIso8601String();
        return _localBookings[idx];
      }
      rethrow;
    }
  }

  Future<bool> deleteBooking(String bookingId) async {
    lastError = null;
    try {
      final headers = await _headers();
      if (headers == null || bookingId.startsWith('local_')) {
        final idx = _localBookings.indexWhere((b) => b['_id'] == bookingId);
        if (idx != -1) {
          _localBookings.removeAt(idx);
          return true;
        }
        return false;
      }

      final baseUrl = await AuthService.instance.getActiveBackendUrl();
      final response = await http
          .delete(
            Uri.parse('$baseUrl/api/prescripto/bookings/$bookingId'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        return true;
      }
      final errData = jsonDecode(response.body);
      throw Exception(errData['error'] ?? 'Failed to delete booking');
    } catch (e) {
      debugPrint('PrescriptoService.deleteBooking error: $e');
      lastError = e.toString();
      final idx = _localBookings.indexWhere((b) => b['_id'] == bookingId);
      if (idx != -1) {
        _localBookings.removeAt(idx);
        return true;
      }
      rethrow;
    }
  }

  List<Map<String, dynamic>> _mockDoctorsLocal() {
    return [
      {
        '_id': 'd001',
        'name': 'Dr. Anjali Sharma',
        'specialty': 'General Physician',
        'hospital': 'City Health Centre',
        'experience': 12,
        'rating': 4.9,
        'consultationFee': 500,
        'profileImage': 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=300',
        'isAvailable': true
      },
      {
        '_id': 'd002',
        'name': 'Dr. Rahul Verma',
        'specialty': 'Cardiology',
        'hospital': 'Apollo Hospitals',
        'experience': 15,
        'rating': 4.7,
        'consultationFee': 1000,
        'profileImage': 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&q=80&w=300',
        'isAvailable': true
      },
      {
        '_id': 'd003',
        'name': 'Dr. Neha Singh',
        'specialty': 'Dermatology',
        'hospital': 'Skin & Care Clinic',
        'experience': 8,
        'rating': 4.8,
        'consultationFee': 700,
        'profileImage': 'https://images.unsplash.com/photo-1594824813573-246434de83fb?auto=format&fit=crop&q=80&w=300',
        'isAvailable': true
      },
      {
        '_id': 'd004',
        'name': 'Dr. Amit Patel',
        'specialty': 'Dentistry',
        'hospital': 'Bright Smile Dental',
        'experience': 10,
        'rating': 4.6,
        'consultationFee': 600,
        'profileImage': 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?auto=format&fit=crop&q=80&w=300',
        'isAvailable': false
      },
      {
        '_id': 'd005',
        'name': 'Dr. Priya Nair',
        'specialty': 'Gynecology',
        'hospital': 'Metropolis Hospital',
        'experience': 14,
        'rating': 4.9,
        'consultationFee': 800,
        'profileImage': 'https://images.unsplash.com/photo-1614608682850-e0d6ed316d47?auto=format&fit=crop&q=80&w=300',
        'isAvailable': true
      },
      {
        '_id': 'd006',
        'name': 'Dr. Vikram Mehta',
        'specialty': 'Neurology',
        'hospital': 'Brain & Spine Institute',
        'experience': 18,
        'rating': 4.9,
        'consultationFee': 1200,
        'profileImage': 'https://images.unsplash.com/photo-1536064485894-ce84015ef3b5?auto=format&fit=crop&q=80&w=300',
        'isAvailable': true
      },
      {
        '_id': 'd007',
        'name': 'Dr. Rajesh Kumar',
        'specialty': 'Orthopedics',
        'hospital': 'Fortis Healthcare',
        'experience': 11,
        'rating': 4.5,
        'consultationFee': 650,
        'profileImage': 'https://images.unsplash.com/photo-1607990283143-e81e7a2c93ab?auto=format&fit=crop&q=80&w=300',
        'isAvailable': true
      },
      {
        '_id': 'd008',
        'name': 'Dr. Kavita Rao',
        'specialty': 'Pediatrics',
        'hospital': 'Kids Care Hospital',
        'experience': 9,
        'rating': 4.8,
        'consultationFee': 600,
        'profileImage': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&q=80&w=300',
        'isAvailable': true
      },
      {
        '_id': 'd009',
        'name': 'Dr. Sanjay Dutt',
        'specialty': 'Psychiatry',
        'hospital': 'Mind & Soul Wellness',
        'experience': 16,
        'rating': 4.7,
        'consultationFee': 900,
        'profileImage': 'https://images.unsplash.com/photo-1582750433449-64c656df174a?auto=format&fit=crop&q=80&w=300',
        'isAvailable': true
      },
      {
        '_id': 'd010',
        'name': 'Dr. Alok Mishra',
        'specialty': 'Ophthalmology',
        'hospital': 'Netradham Eye Hospital',
        'experience': 13,
        'rating': 4.6,
        'consultationFee': 500,
        'profileImage': 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&q=80&w=300',
        'isAvailable': true
      }
    ];
  }
}
