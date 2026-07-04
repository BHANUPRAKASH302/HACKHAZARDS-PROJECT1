import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestAttempt {
  final String id;
  final String courseTitle;
  final String date;
  final String time;
  final int score;

  const TestAttempt({
    required this.id,
    required this.courseTitle,
    required this.date,
    required this.time,
    required this.score,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseTitle': courseTitle,
        'date': date,
        'time': time,
        'score': score,
      };

  factory TestAttempt.fromJson(Map<String, dynamic> json) => TestAttempt(
        id: json['id'] as String,
        courseTitle: json['courseTitle'] as String,
        date: json['date'] as String,
        time: json['time'] as String,
        score: json['score'] as int,
      );
}

class TestHistoryNotifier extends StateNotifier<List<TestAttempt>> {
  TestHistoryNotifier() : super([]) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('test_attempts') ?? [];
      state = list
          .map((item) => TestAttempt.fromJson(jsonDecode(item) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Handle error gracefully
    }
  }

  Future<void> addAttempt(String courseTitle, int score) async {
    final now = DateTime.now();
    final dateStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final timeStr =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    final attempt = TestAttempt(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      courseTitle: courseTitle,
      date: dateStr,
      time: timeStr,
      score: score,
    );

    state = [attempt, ...state];

    try {
      final prefs = await SharedPreferences.getInstance();
      final list = state.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList('test_attempts', list);
    } catch (e) {
      // Handle error
    }
  }
}

final testHistoryProvider =
    StateNotifierProvider<TestHistoryNotifier, List<TestAttempt>>((ref) {
  return TestHistoryNotifier();
});
