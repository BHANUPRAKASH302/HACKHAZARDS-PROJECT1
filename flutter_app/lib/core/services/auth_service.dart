import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'api_config.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _tokenKey = 'auth_token';
  static const _userEmailKey = 'user_email';
  static const _userNameKey = 'user_name';
  static const _userJsonKey = 'user_json';
  static const _activeBackendUrlKey = 'active_backend_url';
  static const _localDemoToken = 'local-demo-token';
  static const _googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: '612194989903-vvtg0m7sa9io315kcfj06q1iggl1ncr1.apps.googleusercontent.com',
  );

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? null
        : _googleClientId,
    serverClientId: _googleClientId,
    scopes: const ['email', 'profile'],
  );

  String? lastError;

  Future<List<String>> _candidateAuthUrls() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_activeBackendUrlKey);
    final bases = <String>[
      if (saved != null && saved.isNotEmpty) saved,
      ...ApiConfig.candidateBaseUrls,
    ];
    return bases.toSet().map((base) => '$base/api/auth').toList();
  }

  Future<String> getActiveBackendUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeBackendUrlKey) ?? ApiConfig.baseUrl;
  }

  Future<void> _saveActiveBackendUrl(String authUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _activeBackendUrlKey,
      authUrl.replaceFirst(RegExp(r'/api/auth$'), ''),
    );
  }

  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    Object? lastNetworkError;
    for (final authUrl in await _candidateAuthUrls()) {
      try {
        final response = await http
            .post(
              Uri.parse('$authUrl$path'),
              headers: {
                'Content-Type': 'application/json',
                if (token != null) 'Authorization': 'Bearer $token',
              },
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 8));

        final data = response.body.isEmpty
            ? <String, dynamic>{}
            : jsonDecode(response.body) as Map<String, dynamic>;
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw AuthException(data['error']?.toString() ?? 'Request failed');
        }
        await _saveActiveBackendUrl(authUrl);
        return data;
      } on AuthException {
        rethrow;
      } catch (e) {
        lastNetworkError = e;
      }
    }
    throw AuthException(
      'Unable to reach the authentication server.'
      '${kDebugMode && lastNetworkError != null ? ' Check backend URL/port.' : ''}',
    );
  }

  Future<void> _saveSession(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await _secureStorage.write(key: _tokenKey, value: token);
    await prefs.setString(_userEmailKey, user['email']?.toString() ?? '');
    await prefs.setString(
      _userNameKey,
      (user['fullName'] ?? user['name'] ?? 'User').toString(),
    );
    await prefs.setString(_userJsonKey, jsonEncode(user));
  }

  Future<void> saveUserSnapshot(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, user['email']?.toString() ?? '');
    await prefs.setString(
      _userNameKey,
      (user['fullName'] ?? user['name'] ?? 'User').toString(),
    );
    await prefs.setString(_userJsonKey, jsonEncode(user));
  }

  Future<void> saveToken(String token) async {
    if (token.isEmpty) {
      await _secureStorage.delete(key: _tokenKey);
    } else {
      await _secureStorage.write(key: _tokenKey, value: token);
    }
  }

  Future<String?> getToken() async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null || token.isEmpty) return null;
    return token;
  }

  Future<bool> isLocalDemoSession() async {
    return await getToken() == _localDemoToken;
  }

  Future<bool> login(String email, String password) async {
    lastError = null;
    final normalizedEmail = email.trim().toLowerCase();
    try {
      final data = await _postJson('/login', {
        'email': normalizedEmail,
        'password': password,
      });

      if (data['token'] != null && data['user'] is Map<String, dynamic>) {
        await _saveSession(data['token'].toString(), data['user']);
        return true;
      }
      lastError = 'Additional verification is required.';
    } on AuthException catch (e) {
      lastError = e.message;
      if (kDebugMode &&
          normalizedEmail == 'demo@multidomain.ai' &&
          password == 'Demo@1234' &&
          e.message.startsWith('Unable to reach')) {
        await _saveSession(_localDemoToken, _demoUser());
        lastError = null;
        return true;
      }
    } catch (e) {
      lastError = 'Unable to reach the authentication server.';
      debugPrint('Login Error: $e');
    }
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    lastError = null;
    try {
      final data = await _postJson('/register', {
        'fullName': name.trim(),
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
      });

      if (data['token'] != null && data['user'] is Map<String, dynamic>) {
        await _saveSession(data['token'].toString(), data['user']);
        return true;
      }
      lastError = 'Account created, but login could not be completed.';
    } on AuthException catch (e) {
      lastError = e.message;
    } catch (e) {
      lastError = 'Unable to reach the authentication server.';
      debugPrint('Register Error: $e');
    }
    return false;
  }

  Future<bool> loginWithGoogle() async {
    lastError = null;
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        lastError = 'Google Sign-In was cancelled.';
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      if (idToken == null) {
        lastError = 'Google did not return an identity token.';
        return false;
      }

      final data = await _postJson('/google', {'idToken': idToken});
      if (data['token'] != null && data['user'] is Map<String, dynamic>) {
        await _saveSession(data['token'].toString(), data['user']);
        return true;
      }
      lastError = 'Additional verification is required.';
    } on AuthException catch (e) {
      lastError = e.message;
    } catch (e) {
      lastError = 'Google Sign-In failed. Check backend and OAuth configuration.';
      debugPrint('Google Sign-In Error: $e');
    }
    return false;
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return false;
    if (token == _localDemoToken) return true;

    try {
      for (final authUrl in await _candidateAuthUrls()) {
        final response = await http.get(
          Uri.parse('$authUrl/me'),
          headers: {'Authorization': 'Bearer $token'},
        ).timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          await _saveActiveBackendUrl(authUrl);
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          if (data['user'] is Map<String, dynamic>) {
            await saveUserSnapshot(data['user']);
          }
          return true;
        }
      }
    } catch (e) {
      debugPrint('Session check failed: $e');
      return true;
    }

    await logout();
    return false;
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  Future<Map<String, dynamic>?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userJsonKey);
    if (raw == null || raw.isEmpty) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<String?> requestPasswordReset(String email) async {
    lastError = null;
    try {
      final data = await _postJson('/forgot-password', {'email': email.trim()});
      return data['resetToken']?.toString();
    } on AuthException catch (e) {
      lastError = e.message;
    } catch (e) {
      lastError = 'Unable to request password reset.';
      debugPrint('Forgot Password Error: $e');
    }
    return null;
  }

  Future<bool> resetPassword(String token, String password) async {
    lastError = null;
    try {
      await _postJson('/reset-password', {'token': token.trim(), 'password': password});
      return true;
    } on AuthException catch (e) {
      lastError = e.message;
    } catch (e) {
      lastError = 'Unable to reset password.';
      debugPrint('Reset Password Error: $e');
    }
    return false;
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    lastError = null;
    try {
      final token = await getToken();
      if (token == null) throw const AuthException('Session expired. Please log in again.');
      final data = await _postJson(
        '/change-password',
        {'currentPassword': currentPassword, 'newPassword': newPassword},
        token: token,
      );
      if (data['token'] != null) await saveToken(data['token'].toString());
      if (data['user'] is Map<String, dynamic>) await saveUserSnapshot(data['user']);
      return true;
    } on AuthException catch (e) {
      lastError = e.message;
    } catch (e) {
      lastError = 'Unable to change password.';
      debugPrint('Change Password Error: $e');
    }
    return false;
  }

  Future<void> logout() async {
    final token = await getToken();
    if (token != null && token != _localDemoToken) {
      try {
        await _postJson('/logout', {}, token: token);
      } catch (_) {
        // Local logout still succeeds when the server is unreachable.
      }
    }
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await _secureStorage.delete(key: _tokenKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userJsonKey);
  }

  Map<String, dynamic> _demoUser() {
    return {
      'id': 'local-demo-user',
      'userId': 'local-demo-user',
      'fullName': 'Demo User',
      'name': 'Demo User',
      'email': 'demo@multidomain.ai',
      'profileImage': '',
      'bio': 'Local demo account',
      'phoneNumber': '',
      'preferences': {'notifications': true, 'soundEffects': true},
      'loginMethod': 'demo',
      'loginProvider': 'demo',
      'createdAt': DateTime.now().toIso8601String(),
      'lastLoginAt': DateTime.now().toIso8601String(),
      'profileUpdateHistory': [],
      'firstName': 'Demo',
      'lastName': 'User',
      'role': 'Full Stack Developer',
      'location': 'New York, USA',
      'instagram': 'https://instagram.com/demouser',
      'linkedin': 'https://linkedin.com/in/demouser',
      'github': 'https://github.com/demouser',
      'x': 'https://x.com/demouser',
      'telegram': 'https://web.telegram.org/a/#8873481129',
    };
  }

  Future<bool> verifyOtp(String otp) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return otp.length == 6;
  }
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
}

final authStateProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false) {
    _checkSession();
  }

  Future<void> _checkSession() async {
    final loggedIn = await AuthService.instance.isLoggedIn();
    state = loggedIn;
  }

  Future<bool> login(String email, String password) async {
    final result = await AuthService.instance.login(email, password);
    if (result) state = true;
    return result;
  }

  Future<bool> register(String name, String email, String password) async {
    final result = await AuthService.instance.register(name, email, password);
    if (result) state = true;
    return result;
  }

  Future<bool> loginWithGoogle() async {
    final result = await AuthService.instance.loginWithGoogle();
    if (result) state = true;
    return result;
  }

  Future<void> logout() async {
    await AuthService.instance.logout();
    state = false;
  }

  void markLoggedOut() {
    state = false;
  }
}
