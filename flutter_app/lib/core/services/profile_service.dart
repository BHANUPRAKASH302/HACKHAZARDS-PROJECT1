import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ProfileService {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  String? lastError;

  Future<Map<String, String>?> _headers() async {
    final token = await AuthService.instance.getToken();
    if (token == null) return null;
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Map<String, dynamic>? _decodeUserResponse(http.Response response) {
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }
    throw ProfileException(data['error']?.toString() ?? 'Profile request failed');
  }

  Future<Map<String, dynamic>?> getProfile() async {
    lastError = null;
    try {
      final headers = await _headers();
      if (headers == null) return null;
      if (await AuthService.instance.isLocalDemoSession()) {
        return await AuthService.instance.getCachedUser();
      }
      final baseUrl = await AuthService.instance.getActiveBackendUrl();

      final response = await http
          .get(Uri.parse('$baseUrl/api/profile'), headers: headers)
          .timeout(const Duration(seconds: 12));

      final user = _decodeUserResponse(response);
      if (user != null) await AuthService.instance.saveUserSnapshot(user);
      return user;
    } on ProfileException catch (e) {
      lastError = e.message;
    } catch (e) {
      lastError = 'Unable to load profile.';
      debugPrint('Get Profile Error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> updateProfile({
    String? fullName,
    String? name,
    String? email,
    String? phoneNumber,
    String? bio,
    String? profileImage,
    Map<String, dynamic>? preferences,
    String? firstName,
    String? lastName,
    String? role,
    String? location,
    String? instagram,
    String? linkedin,
    String? github,
    String? x,
    String? telegram,
  }) async {
    lastError = null;
    try {
      final headers = await _headers();
      if (headers == null) throw const ProfileException('Session expired. Please log in again.');
      final localDemo = await AuthService.instance.isLocalDemoSession();

      final body = <String, dynamic>{};
      if (fullName != null || name != null) body['fullName'] = fullName ?? name;
      if (email != null) body['email'] = email;
      if (phoneNumber != null) body['phoneNumber'] = phoneNumber;
      if (bio != null) body['bio'] = bio;
      if (profileImage != null) body['profileImage'] = profileImage;
      if (preferences != null) body['preferences'] = preferences;
      if (firstName != null) body['firstName'] = firstName;
      if (lastName != null) body['lastName'] = lastName;
      if (role != null) body['role'] = role;
      if (location != null) body['location'] = location;
      if (instagram != null) body['instagram'] = instagram;
      if (linkedin != null) body['linkedin'] = linkedin;
      if (github != null) body['github'] = github;
      if (x != null) body['x'] = x;
      if (telegram != null) body['telegram'] = telegram;

      if (localDemo) {
        final cached = await AuthService.instance.getCachedUser() ?? <String, dynamic>{};
        final updated = {
          ...cached,
          if (body['fullName'] != null) 'fullName': body['fullName'],
          if (body['fullName'] != null) 'name': body['fullName'],
          if (body['email'] != null) 'email': body['email'],
          if (body['phoneNumber'] != null) 'phoneNumber': body['phoneNumber'],
          if (body['bio'] != null) 'bio': body['bio'],
          if (body['profileImage'] != null) 'profileImage': body['profileImage'],
          if (body['firstName'] != null) 'firstName': body['firstName'],
          if (body['lastName'] != null) 'lastName': body['lastName'],
          if (body['role'] != null) 'role': body['role'],
          if (body['location'] != null) 'location': body['location'],
          if (body['instagram'] != null) 'instagram': body['instagram'],
          if (body['linkedin'] != null) 'linkedin': body['linkedin'],
          if (body['github'] != null) 'github': body['github'],
          if (body['x'] != null) 'x': body['x'],
          if (body['telegram'] != null) 'telegram': body['telegram'],
          if (body['preferences'] != null)
            'preferences': {
              ...(cached['preferences'] as Map? ?? {}),
              ...body['preferences'] as Map<String, dynamic>,
            },
        };
        await AuthService.instance.saveUserSnapshot(updated);
        return updated;
      }

      final baseUrl = await AuthService.instance.getActiveBackendUrl();

      final response = await http
          .patch(
            Uri.parse('$baseUrl/api/profile'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      final user = _decodeUserResponse(response);
      if (user != null) await AuthService.instance.saveUserSnapshot(user);
      return user;
    } on ProfileException catch (e) {
      lastError = e.message;
    } catch (e) {
      lastError = 'Unable to update profile.';
      debugPrint('Update Profile Error: $e');
    }
    return null;
  }

  Future<bool> deleteAccount() async {
    lastError = null;
    try {
      final headers = await _headers();
      if (headers == null) throw const ProfileException('Session expired. Please log in again.');
      final baseUrl = await AuthService.instance.getActiveBackendUrl();

      final response = await http
          .delete(Uri.parse('$baseUrl/api/profile'), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await AuthService.instance.logout();
        return true;
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      throw ProfileException(data['error']?.toString() ?? 'Account deletion failed');
    } on ProfileException catch (e) {
      lastError = e.message;
    } catch (e) {
      lastError = 'Unable to delete account.';
      debugPrint('Delete Account Error: $e');
    }
    return false;
  }
}

class ProfileException implements Exception {
  const ProfileException(this.message);
  final String message;
}
