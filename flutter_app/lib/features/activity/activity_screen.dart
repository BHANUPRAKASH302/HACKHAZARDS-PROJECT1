import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import './test_history_provider.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testHistory = ref.watch(testHistoryProvider);

    String learningSummary = 'Learnt Python core loops, practiced list comprehensions, and generated a study plan for flutter state management with Jarvis.';
    if (testHistory.isNotEmpty) {
      final latest = testHistory.first;
      learningSummary += '\n\nLatest Test: "${latest.courseTitle}" (Score: ${latest.score}/10)';
    }

    final activityData = [
      {
        'domain': 'Learning',
        'time': '4h 30m',
        'color': AppColors.eduCyan,
        'progress': 0.8,
        'aiConversation': learningSummary,
      },
      {
        'domain': 'Prescripto',
        'time': '1h 15m',
        'color': AppColors.medicalBlue,
        'progress': 0.3,
        'aiConversation': 'Discussed drug side-effects of common antibiotics and analyzed symptoms for a mock consultation.',
      },
      {
        'domain': 'LawGen AI',
        'time': '2h 00m',
        'color': AppColors.legalGold,
        'progress': 0.5,
        'aiConversation': 'Drafted a mutual non-disclosure agreement and asked Jarvis about key legal liability clauses.',
      },
      {
        'domain': 'AgroGen',
        'time': '45m',
        'color': AppColors.agriGreen,
        'progress': 0.15,
        'aiConversation': 'Evaluated crop rotation strategies and fertilizer dosages for tomato plants to increase yield.',
      },
      {
        'domain': 'SafeGuard AI',
        'time': '10m',
        'color': AppColors.alertRed,
        'progress': 0.05,
        'aiConversation': 'Analyzed safety procedures and drafted an emergency contact plan for building security protocols.',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Activity Tracking', style: AppTextStyles.h2),
        iconTheme: IconThemeData(color: AppColors.textWhite),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text('Time Spent per Domain', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          // Time spent per domain list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activityData.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = activityData[index];
              final color = item['color'] as Color;
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item['domain'] as String, style: AppTextStyles.labelLarge),
                        Text(item['time'] as String, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textGray)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: item['progress'] as double,
                      backgroundColor: color.withOpacity(0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 14,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cardElevated.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border.withOpacity(0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_awesome, color: color, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'AI CONVERSATION & WORK',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item['aiConversation'] as String,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textGray,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          Text('Course Test History', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          // Test attempt history list
          if (testHistory.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Text(
                  'No tests taken yet. Start by taking a quiz in course details!',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGray),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: testHistory.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final attempt = testHistory[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryPurple.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.secondaryPurple.withOpacity(0.3)),
                        ),
                        child: const Center(
                          child: Icon(Icons.quiz_outlined, color: AppColors.secondaryPurple, size: 24),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              attempt.courseTitle,
                              style: AppTextStyles.labelLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Taken: ${attempt.date} ${attempt.time}',
                              style: AppTextStyles.caption.copyWith(color: AppColors.textGray),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: (attempt.score >= 7 ? AppColors.successGreen : AppColors.secondaryPurple).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Score: ${attempt.score}/10',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: attempt.score >= 7 ? AppColors.successGreen : AppColors.secondaryPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
