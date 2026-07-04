import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class SafeguardService {
  SafeguardService._();
  static final SafeguardService instance = SafeguardService._();

  static const _contactsLocalKey = 'safeguard_contacts_local';
  static const _firLocalKey = 'safeguard_fir_local';

  Future<Map<String, String>?> _headers() async {
    final token = await AuthService.instance.getToken();
    if (token == null) return null;
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // --- Contacts Operations ---
  Future<List<Map<String, dynamic>>> getContacts() async {
    try {
      final isDemo = await AuthService.instance.isLocalDemoSession();
      final token = await AuthService.instance.getToken();
      if (isDemo || token == null) {
        return _getLocalContacts();
      }

      final headers = await _headers();
      if (headers == null) return _getLocalContacts();

      final baseUrl = await AuthService.instance.getActiveBackendUrl();
      final response = await http
          .get(Uri.parse('$baseUrl/api/safeguard/contacts'), headers: headers)
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> list = body['data'] ?? [];
        final contacts = list.map((e) => e as Map<String, dynamic>).toList();
        await _saveLocalContacts(contacts);
        return contacts;
      }
    } catch (e) {
      debugPrint('Error getting contacts from backend: $e');
    }
    return _getLocalContacts();
  }

  Future<bool> addContact(String name, String phone, String relation) async {
    try {
      final isDemo = await AuthService.instance.isLocalDemoSession();
      final token = await AuthService.instance.getToken();
      if (isDemo || token == null) {
        return _addLocalContact(name, phone, relation);
      }

      final headers = await _headers();
      if (headers == null) return _addLocalContact(name, phone, relation);

      final baseUrl = await AuthService.instance.getActiveBackendUrl();
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/safeguard/contacts'),
            headers: headers,
            body: jsonEncode({'name': name, 'phone': phone, 'relation': relation}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> list = body['data'] ?? [];
        await _saveLocalContacts(list.map((e) => e as Map<String, dynamic>).toList());
        return true;
      }
    } catch (e) {
      debugPrint('Error adding contact to backend: $e');
    }
    return _addLocalContact(name, phone, relation);
  }

  Future<bool> _addLocalContact(String name, String phone, String relation) async {
    final contacts = await _getLocalContacts();
    if (contacts.length >= 3) return false;
    contacts.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'phone': phone,
      'relation': relation
    });
    await _saveLocalContacts(contacts);
    return true;
  }

  Future<bool> deleteContact(String id) async {
    try {
      final isDemo = await AuthService.instance.isLocalDemoSession();
      final token = await AuthService.instance.getToken();
      if (isDemo || token == null) {
        return _deleteLocalContact(id);
      }

      final headers = await _headers();
      if (headers == null) return _deleteLocalContact(id);

      final baseUrl = await AuthService.instance.getActiveBackendUrl();
      final response = await http
          .delete(Uri.parse('$baseUrl/api/safeguard/contacts/$id'), headers: headers)
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> list = body['data'] ?? [];
        await _saveLocalContacts(list.map((e) => e as Map<String, dynamic>).toList());
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting contact from backend: $e');
    }
    return _deleteLocalContact(id);
  }

  Future<bool> _deleteLocalContact(String id) async {
    final contacts = await _getLocalContacts();
    contacts.removeWhere((c) => c['id'] == id);
    await _saveLocalContacts(contacts);
    return true;
  }

  Future<List<Map<String, dynamic>>> _getLocalContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_contactsLocalKey);
    if (data == null) {
      // Default mock contacts if nothing is saved
      return [
        {'id': '1', 'name': 'Mom', 'phone': '+91 98765 43210', 'relation': 'Family'},
        {'id': '2', 'name': 'Dad', 'phone': '+91 91234 56789', 'relation': 'Family'},
        {'id': '3', 'name': 'Riya (Friend)', 'phone': '+91 87654 32109', 'relation': 'Friend'},
      ];
    }
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<void> _saveLocalContacts(List<Map<String, dynamic>> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_contactsLocalKey, jsonEncode(contacts));
  }

  // --- FIR Operations ---
  Future<List<Map<String, dynamic>>> getFirs() async {
    try {
      final isDemo = await AuthService.instance.isLocalDemoSession();
      final token = await AuthService.instance.getToken();
      if (isDemo || token == null) {
        return _getLocalFirs();
      }

      final headers = await _headers();
      if (headers == null) return _getLocalFirs();

      final baseUrl = await AuthService.instance.getActiveBackendUrl();
      final response = await http
          .get(Uri.parse('$baseUrl/api/safeguard/fir'), headers: headers)
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> list = body['data'] ?? [];
        final firs = list.map((e) => e as Map<String, dynamic>).toList();
        await _saveLocalFirs(firs);
        return firs;
      }
    } catch (e) {
      debugPrint('Error getting FIRs from backend: $e');
    }
    return _getLocalFirs();
  }

  Future<Map<String, dynamic>?> createFir(Map<String, dynamic> data) async {
    try {
      final isDemo = await AuthService.instance.isLocalDemoSession();
      final token = await AuthService.instance.getToken();

      if (isDemo || token == null) {
        return _createLocalFir(data);
      }

      final headers = await _headers();
      if (headers == null) return _createLocalFir(data);

      final baseUrl = await AuthService.instance.getActiveBackendUrl();
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/safeguard/fir'),
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final Map<String, dynamic> newFir = body['data'] ?? {};
        // Cache it locally too
        final localFirs = await _getLocalFirs();
        localFirs.add(newFir);
        await _saveLocalFirs(localFirs);
        return newFir;
      }
    } catch (e) {
      debugPrint('Error creating FIR: $e');
    }
    return _createLocalFir(data);
  }

  Future<Map<String, dynamic>> _createLocalFir(Map<String, dynamic> data) async {
    final firs = await _getLocalFirs();
    final firNumber = 'FIR-' + (100000 + DateTime.now().millisecond * 9).toString();
    final newFir = {
      'firNumber': firNumber,
      'registrationDateTime': DateTime.now().toIso8601String(),
      'complainantDetails': {
        'fullName': data['fullName'],
        'age': data['age'],
        'occupation': data['occupation'],
        'permanentAddress': data['permanentAddress'],
        'temporaryAddress': data['temporaryAddress'],
        'contactNumber': data['contactNumber'],
      },
      'firDetails': {
        'incidentNarrative': data['incidentNarrative'],
        'incidentDate': data['incidentDate'],
        'incidentTime': data['incidentTime'],
        'incidentLocation': data['incidentLocation'],
        'crimeDescription': data['crimeDescription'],
        'motives': data['motives'],
        'propertyStolen': data['propertyStolen'],
        'weaponsUsed': data['weaponsUsed'],
      },
      'specificLaws': data['specificLaws'] ?? 'BNS Section 303 / IPC Section 379 - Theft'
    };
    firs.add(newFir);
    await _saveLocalFirs(firs);
    return newFir;
  }

  Future<bool> deleteFir(String firNumber) async {
    try {
      final isDemo = await AuthService.instance.isLocalDemoSession();
      final token = await AuthService.instance.getToken();
      if (isDemo || token == null) {
        final firs = await _getLocalFirs();
        firs.removeWhere((f) => f['firNumber'] == firNumber);
        await _saveLocalFirs(firs);
        return true;
      }

      final headers = await _headers();
      if (headers == null) {
        final firs = await _getLocalFirs();
        firs.removeWhere((f) => f['firNumber'] == firNumber);
        await _saveLocalFirs(firs);
        return true;
      }

      final baseUrl = await AuthService.instance.getActiveBackendUrl();
      final response = await http
          .delete(Uri.parse('$baseUrl/api/safeguard/fir/$firNumber'), headers: headers)
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final firs = await _getLocalFirs();
        firs.removeWhere((f) => f['firNumber'] == firNumber);
        await _saveLocalFirs(firs);
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting FIR: $e');
    }
    final firs = await _getLocalFirs();
    firs.removeWhere((f) => f['firNumber'] == firNumber);
    await _saveLocalFirs(firs);
    return true;
  }

  Future<List<Map<String, dynamic>>> _getLocalFirs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_firLocalKey);
    if (data == null) return [];
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<void> _saveLocalFirs(List<Map<String, dynamic>> firs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_firLocalKey, jsonEncode(firs));
  }
}
