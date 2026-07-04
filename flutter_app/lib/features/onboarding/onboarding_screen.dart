import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/router/app_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Premium Cosmic Background Gradients
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryPurple.withOpacity(0.2),
                    AppColors.secondaryPurple.withOpacity(0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00E5FF).withOpacity(0.12),
                    AppColors.secondaryPurple.withOpacity(0.03),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: MediaQuery.of(context).size.width * 0.2,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondaryPurple.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Scrollable Layout
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // Diamond Logo inside a Glowing Neon/Glass card
                  Center(
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryPurple.withOpacity(0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryPurple.withOpacity(0.35),
                            blurRadius: 25,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withOpacity(0.15),
                            blurRadius: 15,
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF0B0721), // Dark space blue
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Text(
                                '💎',
                                style: TextStyle(fontSize: 42),
                              ),
                              Positioned(
                                top: 22,
                                right: 20,
                                child: Text(
                                  '✦',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.cyanAccent.withOpacity(0.8),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 24,
                                left: 18,
                                child: Text(
                                  '✦',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.purpleAccent.withOpacity(0.8),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .scale(duration: 800.ms, curve: Curves.elasticOut)
                      .fadeIn(duration: 500.ms),

                  const SizedBox(height: 20),

                  // Gradient/Masked Display Title
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, Color(0xFFE2E8F0), Color(0xFFC084FC)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds),
                    child: Text(
                      'Your AI Companion',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.displayMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 27,
                      ),
                    ),
                  ).animate().fadeIn(delay: 150.ms, duration: 500.ms),

                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF22D3EE), Color(0xFF0EA5E9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      'Across Every Domain',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.displayMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 27,
                        height: 1.15,
                      ),
                    ),
                  ).animate().fadeIn(delay: 250.ms, duration: 500.ms),

                  const SizedBox(height: 14),

                  Text(
                    'One intelligent platform. Multiple expert solutions.\nSmarter assistance for a better tomorrow.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textGray.withOpacity(0.85),
                      height: 1.45,
                      fontSize: 12.5,
                    ),
                  ).animate().fadeIn(delay: 350.ms, duration: 500.ms),

                  const SizedBox(height: 28),

                  // Explore Domains Header
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, AppColors.border.withOpacity(0.35)],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          'Explore Domains',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textWhite,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.border.withOpacity(0.35), Colors.transparent],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 450.ms),

                  const SizedBox(height: 18),

                  // Domain cards grid
                  // Row 1: Education, Healthcare, Legal
                  Row(
                    children: [
                      Expanded(
                        child: const _DomainCard(
                          title: 'Education',
                          subtitle: 'Smart learning support, anytime anywhere.',
                          icon: Icons.school_rounded,
                          color: AppColors.eduCyan,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: const _DomainCard(
                          title: 'Healthcare',
                          subtitle: 'Your health, our priority. Always here for you.',
                          icon: Icons.local_hospital_rounded,
                          color: AppColors.alertRed,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: const _DomainCard(
                          title: 'Legal',
                          subtitle: 'Reliable legal guidance, simplified.',
                          icon: Icons.balance_rounded,
                          color: AppColors.legalGold,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 500.ms, duration: 500.ms),

                  const SizedBox(height: 8),

                  // Row 2: Agriculture, Safety & SOS (Centered)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: (screenWidth - 48) / 3 * 1.5,
                        child: const _DomainCard(
                          title: 'Agriculture',
                          subtitle: 'Smart farming solutions for a better harvest.',
                          icon: Icons.grass_rounded,
                          color: AppColors.agriGreen,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: (screenWidth - 48) / 3 * 1.5,
                        child: const _DomainCard(
                          title: 'Safety & SOS',
                          subtitle: 'Instant help, maximum safety, always with you.',
                          icon: Icons.security_rounded,
                          color: AppColors.safetyOrange,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 600.ms, duration: 500.ms),

                  const SizedBox(height: 32),

                  // Features Grid Box (AI Powered, Secure, 24/7, Multiple)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B0920).withOpacity(0.55),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primaryPurple.withOpacity(0.12),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const _FeatureItem(
                          icon: Icons.bolt_rounded,
                          line1: 'AI Powered',
                          line2: 'Smart & Fast',
                        ),
                        _verticalDivider(),
                        const _FeatureItem(
                          icon: Icons.verified_user_rounded,
                          line1: 'Secure',
                          line2: '& Private',
                        ),
                        _verticalDivider(),
                        const _FeatureItem(
                          icon: Icons.watch_later_rounded,
                          line1: 'Available',
                          line2: '24/7',
                          is247: true,
                        ),
                        _verticalDivider(),
                        const _FeatureItem(
                          icon: Icons.group_work_rounded,
                          line1: 'Multiple Domains',
                          line2: 'One Platform',
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 700.ms, duration: 500.ms),

                  const SizedBox(height: 28),

                  // Premium Get Started Button
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.login),
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF2563EB)], // Purple to Blue
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            'Get Started',
                            style: AppTextStyles.buttonText.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Positioned(
                            right: 22,
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 800.ms, duration: 500.ms)
                      .scale(delay: 800.ms, begin: const Offset(0.95, 0.95), end: const Offset(1, 1), curve: Curves.easeOutBack),

                  const SizedBox(height: 18),

                  // Already have account link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textGray.withOpacity(0.75),
                          fontSize: 13,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.login),
                        child: Text(
                          'Login',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: const Color(0xFF3B82F6), // blue highlight
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 900.ms),

                  const SizedBox(height: 16),

                  // Agreement
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        color: AppColors.textDimmed.withOpacity(0.5),
                        size: 13,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'By continuing, you agree to our Terms & Conditions & Privacy Policy',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textDimmed.withOpacity(0.5),
                            fontSize: 10.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 1000.ms),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 28,
      color: AppColors.border.withOpacity(0.18),
    );
  }
}

class _DomainCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _DomainCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 145,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF090D1A), // Dark blue card
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.03),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon Container with Glow
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0F172A),
              border: Border.all(
                color: color.withOpacity(0.35),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(height: 10),
          // Title
          Text(
            title,
            style: AppTextStyles.labelLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Subtitle
          Expanded(
            child: Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textGray.withOpacity(0.7),
                fontSize: 10,
                height: 1.25,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String line1;
  final String line2;
  final bool is247;

  const _FeatureItem({
    required this.icon,
    required this.line1,
    required this.line2,
    this.is247 = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          if (is247)
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.watch_later_rounded,
                  color: AppColors.primaryPurple.withOpacity(0.85),
                  size: 20,
                ),
                Positioned(
                  bottom: -1,
                  right: -1,
                  child: Container(
                    padding: const EdgeInsets.all(1.5),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0B0920),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '24/7',
                      style: TextStyle(
                        fontSize: 6,
                        color: Colors.cyanAccent.withOpacity(0.9),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Icon(
              icon,
              color: AppColors.primaryPurple.withOpacity(0.85),
              size: 20,
            ),
          const SizedBox(height: 6),
          // Line 1
          Text(
            line1,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textWhite,
              fontWeight: FontWeight.w600,
              fontSize: 8.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // Line 2
          Text(
            line2,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textGray.withOpacity(0.7),
              fontSize: 8,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
