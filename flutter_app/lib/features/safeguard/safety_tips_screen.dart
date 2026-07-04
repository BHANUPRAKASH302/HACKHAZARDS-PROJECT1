import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class SafetyTipsScreen extends StatelessWidget {
  const SafetyTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tips = [
      {
        'title': 'Travel Security',
        'icon': Icons.card_travel,
        'desc': 'Navigating unfamiliar transit hubs, avoiding local scams, and finding safe neighborhoods.',
        'details': [
          'Plan routes beforehand and avoid display of expensive belongings.',
          'Use registered or verified transit apps instead of hailing unknown vehicles.',
          'Keep copies of travel documents stored securely online.'
        ]
      },
      {
        'title': 'Emergency Assistance',
        'icon': Icons.local_police,
        'desc': 'Contacting local police, ambulance services, or fire departments during crises.',
        'details': [
          'Keep basic emergency hotlines memorized or saved on speed dial.',
          'Provide precise landmarks and GPS coordinates when calling authorities.',
          'Always stay calm and clear while delivering emergency information.'
        ]
      },
      {
        'title': 'Digital Privacy',
        'icon': Icons.security,
        'desc': 'Protecting online accounts from hackers, avoiding phishing links, and securing personal data.',
        'details': [
          'Enable two-factor authentication (2FA) on all financial and social accounts.',
          'Never click links or download attachments from unknown emails.',
          'Use a reputable password manager to generate unique, strong passwords.'
        ]
      },
      {
        'title': 'Home Defense',
        'icon': Icons.home,
        'desc': 'Installing reliable locks, setting up security cameras, and planning fire escape routes.',
        'details': [
          'Use deadbolt locks on all external entryways.',
          'Maintain outdoor lighting and clear visibility around doors and windows.',
          'Establish a simple family emergency fire escape plan with designated meet points.'
        ]
      },
      {
        'title': 'Personal Protection',
        'icon': Icons.shield_outlined,
        'desc': 'De-escalating verbal conflicts, using self-defense tools, and staying aware of surroundings at night.',
        'details': [
          'Stay fully aware of your surroundings; avoid looking down at your phone while walking.',
          'Walk in well-lit, populated pathways especially during late hours.',
          'Carry authorized personal defense items like whistle or pepper spray accessible.'
        ]
      },
      {
        'title': 'Disaster Preparedness',
        'icon': Icons.warning_amber_rounded,
        'desc': 'Storing emergency food, tracking severe weather alerts, and packing a go-bag.',
        'details': [
          'Keep at least a 3-day supply of water and non-perishable food products.',
          'Pack a go-bag containing a first-aid kit, flashlight, batteries, and essential medicines.',
          'Monitor national or local disaster broadcast alerts regularly.'
        ]
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textWhite, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text('SAFETY TIPS', style: AppTextStyles.appBarTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Major Safety Areas',
              style: AppTextStyles.h2.copyWith(color: AppColors.textWhite),
            ),
            const SizedBox(height: 6),
            Text(
              'Essential advice, best practices, and response protocols for daily safety.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGray),
            ),
            const SizedBox(height: 20),
            ...tips.asMap().entries.map((entry) {
              final idx = entry.key;
              final tip = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.secondaryPurple.withOpacity(0.1),
                      child: Icon(tip['icon'] as IconData, color: AppColors.secondaryPurple),
                    ),
                    title: Text(
                      tip['title'] as String,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        tip['desc'] as String,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGray),
                      ),
                    ),
                    iconColor: AppColors.textWhite,
                    collapsedIconColor: AppColors.textGray,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(color: AppColors.border, height: 1),
                            const SizedBox(height: 12),
                            Text(
                              'Actionable Steps:',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.secondaryPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...(tip['details'] as List<String>).map((detail) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('• ', style: TextStyle(color: AppColors.secondaryPurple, fontSize: 16)),
                                    Expanded(
                                      child: Text(
                                        detail,
                                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textWhite),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (idx * 80).ms).slideY(begin: 0.1, end: 0);
            }),
          ],
        ),
      ),
    );
  }
}
