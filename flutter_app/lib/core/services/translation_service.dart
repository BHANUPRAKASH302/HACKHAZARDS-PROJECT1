import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final translationServiceProvider = Provider<TranslationService>((ref) {
  return TranslationService();
});

final currentLanguageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super('English') {
    _loadLang();
  }

  static const _key = 'app_language';

  Future<void> _loadLang() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_key) ?? 'English';
  }

  Future<void> setLanguage(String lang) async {
    state = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, lang);
  }

  String getCode() {
    switch (state) {
      case 'Telugu': return 'te';
      case 'Hindi': return 'hi';
      case 'Bengali': return 'bn';
      case 'Marathi': return 'mr';
      case 'English':
      default:
        return 'en';
    }
  }
}

class TranslationService {
  final String _baseUrl = 'http://127.0.0.1:5000';
  final Map<String, String> _cache = {};

  Future<String> translate(String text, String targetLangCode) async {
    if (targetLangCode == 'en' || text.isEmpty) return text;
    
    final cacheKey = '$targetLangCode:$text';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': text,
          'source': 'auto',
          'target': targetLangCode,
          'format': 'text'
        }),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translatedText = data['translatedText'];
        _cache[cacheKey] = translatedText;
        return translatedText;
      }
    } catch (e) {
      print('Translation error: $e');
    }
    
    return text;
  }
}
