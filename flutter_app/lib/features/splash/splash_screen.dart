import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../core/services/auth_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 3200));
    if (!mounted) return;
    final isLoggedIn = await AuthService.instance.isLoggedIn();
    if (!mounted) return;
    context.go(isLoggedIn ? AppRoutes.home : AppRoutes.onboarding);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background radial glow
          Center(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) => Container(
                width: 300 + (_pulseController.value * 60),
                height: 300 + (_pulseController.value * 60),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryPurple.withOpacity(0.15 + _pulseController.value * 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPurple.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('💎', style: TextStyle(fontSize: 48)),
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      duration: 700.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 500.ms),

                const SizedBox(height: 32),

                // App name
                Text(
                  'Multi-Domain',
                  style: AppTextStyles.displayLarge.copyWith(
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [AppColors.primaryPurple, AppColors.secondaryPurple],
                      ).createShader(const Rect.fromLTWH(0, 0, 300, 60)),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),

                Text(
                  'AI Assistance',
                  style: AppTextStyles.h1.copyWith(color: AppColors.textWhite),
                )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 12),

                Text(
                  'Smart solutions across domains,\nall in one place.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium,
                )
                    .animate()
                    .fadeIn(delay: 800.ms, duration: 600.ms),

                const SizedBox(height: 64),

                // Loading indicator
                SizedBox(
                  width: 160,
                  child: LinearProgressIndicator(
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primaryPurple),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ).animate().fadeIn(delay: 1000.ms, duration: 400.ms),
              ],
            ),
          ),

          // Bottom version text
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Text(
              'v1.0.0  •  HACKHAZARDS \'26',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption,
            ).animate().fadeIn(delay: 1200.ms),
          ),
        ],
      ),
    );
  }
}
