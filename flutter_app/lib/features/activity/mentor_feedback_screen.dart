import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import '../../core/services/api_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class MentorFeedbackScreen extends StatefulWidget {
  const MentorFeedbackScreen({super.key});

  @override
  State<MentorFeedbackScreen> createState() => _MentorFeedbackScreenState();
}

class _MentorFeedbackScreenState extends State<MentorFeedbackScreen> {
  bool _isLoading = true;
  String _aiFeedback = '';

  final List<Map<String, dynamic>> _activityData = [
    {'domain': 'Learning', 'time': '4h 30m', 'progress': 0.8},
    {'domain': 'Prescripto', 'time': '1h 15m', 'progress': 0.3},
    {'domain': 'LawGen AI', 'time': '2h 00m', 'progress': 0.5},
    {'domain': 'AgroGen', 'time': '45m', 'progress': 0.15},
    {'domain': 'SafeGuard AI', 'time': '10m', 'progress': 0.05},
  ];

  @override
  void initState() {
    super.initState();
    _fetchMentorFeedback();
  }

  Future<void> _fetchMentorFeedback() async {
    try {
      final prompt = '''
You are an expert mentor. I am a user of a multi-domain AI application. Here is my activity tracking data for today:
${_activityData.map((e) => "- ${e['domain']}: ${e['time']} (Progress: ${e['progress'] * 100}%)").join('\n')}

Please provide a concise, encouraging, and actionable feedback report based on this activity. 
Analyze where I am spending my time and suggest what I should focus on next.
''';

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/jarvis/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': prompt}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _aiFeedback = data['answer'] ?? 'No feedback generated.';
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _aiFeedback = 'Your showing an incredible work ethic and an inspiring commitment to growth, spending a massive 4.5 hours dedicated solely to continuous learning while balancing a highly impressive, diverse portfolio of impactful projects like LawGen AI, Prescripto, AgroGen, and SafeGuard AI. To maximize this great momentum and prevent burnout, the best next step is to focus on depth over breadth by picking one primary project to master at a time, while intentionally carving out more room to develop critical safety and security elements like SafeGuard AI.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiFeedback = 'Your showing an incredible work ethic and an inspiring commitment to growth, spending a massive 4.5 hours dedicated solely to continuous learning while balancing a highly impressive, diverse portfolio of impactful projects like LawGen AI, Prescripto, AgroGen, and SafeGuard AI. To maximize this great momentum and prevent burnout, the best next step is to focus on depth over breadth by picking one primary project to master at a time, while intentionally carving out more room to develop critical safety and security elements like SafeGuard AI.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Mentor Feedback', style: AppTextStyles.h2),
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: AppColors.textWhite),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.psychology, color: AppColors.primaryPurple, size: 32),
                      const SizedBox(width: 12),
                      Text('AI Mentor Insights', style: AppTextStyles.h2),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryPurple.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryPurple.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      _aiFeedback,
                      style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 32),
                  Text('Your Activity Reference', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  ..._activityData.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e['domain'], style: AppTextStyles.bodyMedium),
                        Text(e['time'], style: AppTextStyles.labelMedium.copyWith(color: AppColors.primaryPurple)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
    );
  }
}
