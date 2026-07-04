import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../data/mock/safeguard_mock.dart';
import '../../shared/widgets/gradient_card.dart';

class SafeguardScreen extends StatelessWidget {
  const SafeguardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: AppColors.textWhite, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text('SAFEGUARD AI', style: AppTextStyles.appBarTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // SOS button card
          GestureDetector(
            onTap: () => context.push(AppRoutes.sos),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.alertRed.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.alertRed.withOpacity(0.4), width: 1.5),
              ),
              child: Row(
                children: [
                  // SOS pulsing button
                  _SosPulse(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SOS',
                            style: AppTextStyles.h2.copyWith(
                                color: AppColors.alertRed)),
                        const SizedBox(height: 2),
                        Text('Emergency Assistance',
                            style: AppTextStyles.bodySmall),
                        const SizedBox(height: 2),
                        Text('Tap to send alert',
                            style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      color: AppColors.alertRed, size: 24),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 300.ms).scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1, 1),
              ),

          const SizedBox(height: 20),

          // Emergency Contact & Online FIR grid
          Row(
            children: [
              Expanded(
                child: _SafeCard(
                  imagePath: 'assets/images/Emergency_Contacts.webp',
                  title: 'Emergency Contact',
                  subtitle: 'Manage contacts',
                  onTap: () => context.push(AppRoutes.emergencyContacts),
                ).animate().fadeIn(delay: 100.ms),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SafeCard(
                  imagePath: 'assets/images/Online_FIR.webp',
                  title: 'Online FIR',
                  subtitle: 'Register report',
                  onTap: () => context.push(AppRoutes.onlineFir),
                ).animate().fadeIn(delay: 150.ms),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _SafeCard(
                  imagePath: 'assets/images/View_FIR.jpg',
                  title: 'View FIR',
                  subtitle: 'Check history',
                  onTap: () => context.push(AppRoutes.viewFir),
                ).animate().fadeIn(delay: 200.ms),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SafeCard(
                  imagePath: 'assets/images/Safety_Tips.jpg',
                  title: 'Safety Tips',
                  subtitle: 'Important safety advice',
                  onTap: () => context.push(AppRoutes.safetyTips),
                ).animate().fadeIn(delay: 250.ms),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Location info
          GradientCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Location', style: AppTextStyles.labelLarge),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        color: AppColors.alertRed, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hyderabad, Telangana', style: AppTextStyles.bodyLarge),
                          const SizedBox(height: 2),
                          Text(
                            'Coordinates: 17.558922, 78.451095',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textGray),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.share_outlined,
                        color: AppColors.textGray, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Sharing with $mockShareWithCount Contacts',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 20),

          // Emergency numbers
          Text('Emergency Numbers', style: AppTextStyles.h3)
              .animate().fadeIn(delay: 350.ms),
          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: emergencyNumbers.entries.map((e) {
              return InkWell(
                onTap: () async {
                  final Uri launchUri = Uri(scheme: 'tel', path: e.value);
                  try {
                    await launchUrl(launchUri);
                  } catch (err) {
                    debugPrint('Error launching dialer: $err');
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: (MediaQuery.of(context).size.width - 42) / 2,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.key, style: AppTextStyles.caption.copyWith(color: AppColors.textGray)),
                            const SizedBox(height: 2),
                            Text(e.value,
                                style: AppTextStyles.h3
                                    .copyWith(color: AppColors.alertRed)),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.alertRed.withOpacity(0.1),
                        child: Icon(Icons.phone, color: AppColors.alertRed, size: 16),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SosPulse extends StatefulWidget {
  @override
  State<_SosPulse> createState() => _SosPulseState();
}

class _SosPulseState extends State<_SosPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.scale(
        scale: _anim.value,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.alertRed,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.alertRed.withOpacity(0.5 * _anim.value),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Center(
            child: Text('SOS',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14)),
          ),
        ),
      ),
    );
  }
}

class _SafeCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SafeCard({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(title,
                style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(subtitle,
                style: AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
