import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/app_button.dart';

class VerifyMethodScreen extends StatelessWidget {
  const VerifyMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Icon(Icons.arrow_back_ios_new,
                      color: AppColors.textWhite, size: 18),
                ),
              ),
              const SizedBox(height: 32),

              Text('2-Step Verification', style: AppTextStyles.h1)
                  .animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 8),
              Text(
                'Select one more method to verify your identity',
                style: AppTextStyles.bodyMedium,
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 32),

              _MethodTile(
                title: 'Authenticator App',
                subtitle: 'Get code from Authenticator App',
                icon: '🔐',
                isSelected: false,
                onTap: () => context.push(AppRoutes.verifyOtp),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 14),

              _MethodTile(
                title: 'SMS Verification',
                subtitle: 'Send update code — +91 86975 43210',
                icon: '📱',
                isSelected: true,
                onTap: () => context.push(AppRoutes.verifyOtp),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 14),

              _MethodTile(
                title: 'Backup Codes',
                subtitle: 'Use one of your backup codes',
                icon: '🛡',
                isSelected: false,
                onTap: () => context.push(AppRoutes.verifyOtp),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),

              const Spacer(),

              AppButton(
                label: 'Continue',
                onPressed: () => context.push(AppRoutes.verifyOtp),
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryPurple
                : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryPurple.withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.labelLarge),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? AppColors.primaryPurple
                  : AppColors.textDimmed,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
