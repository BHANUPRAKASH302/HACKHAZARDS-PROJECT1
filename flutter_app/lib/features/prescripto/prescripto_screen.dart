import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../data/mock/prescripto_mock.dart';
import '../../shared/widgets/gradient_card.dart';

class PrescriptoScreen extends StatelessWidget {
  const PrescriptoScreen({super.key});

  static const _services = [
    _Service(
        iconAsset: 'assets/images/Find_Doctor.png',
        title: 'Find Doctors',
        subtitle: 'Search by specialty'),
    _Service(
        iconAsset: 'assets/images/Doctor_Appointment.jpg',
        title: 'Booked Appointment',
        subtitle: 'Connect with top doctors'),
    _Service(
        iconAsset: 'assets/images/Medical_Records.JPG',
        title: 'Medical Records',
        subtitle: 'View your medical history'),
    _Service(
        iconAsset: 'assets/images/Medicines.JPG',
        title: 'Medicines',
        subtitle: 'Order medicines online'),
    _Service(
        iconAsset: 'assets/images/Health_Articles.jpg',
        title: 'Health Articles',
        subtitle: 'Read expert health tips'),
  ];

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
        title: Text('PRESCRIPTO', style: AppTextStyles.appBarTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header card
          GradientCard(
            glowColor: AppColors.medicalBlue,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Healthcare Services',
                          style: AppTextStyles.h3.copyWith(
                              color: AppColors.medicalBlue)),
                      const SizedBox(height: 4),
                      Text('AI-powered medical assistance',
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppColors.medicalGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/images/Prescripto_Logo.jpg',
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 20),

          // Services
          Text('Services', style: AppTextStyles.h3)
              .animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 12),

          ..._services.asMap().entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ServiceTile(
                service: e.value,
                onTap: () {
                  if (e.key == 0) {
                    context.push(AppRoutes.findDoctors);
                  } else if (e.key == 1) {
                    context.push('/prescripto/bookings');
                  } else if (e.key == 2) {
                    context.push('/prescripto/records');
                  } else if (e.key == 3) {
                    context.push('/prescripto/medicines');
                  } else if (e.key == 4) {
                    context.push('/prescripto/articles');
                  }
                },
              )
                  .animate()
                  .fadeIn(
                      delay: Duration(milliseconds: 120 + 60 * e.key),
                      duration: 350.ms)
                  .slideY(begin: 0.1, end: 0),
            );
          }),

          const SizedBox(height: 20),

          // Recent health records
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Records', style: AppTextStyles.h3),
              TextButton(
                onPressed: () => context.push('/prescripto/records'),
                child: Text('View All',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.secondaryPurple)),
              ),
            ],
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 10),

          ...mockHealthRecords.take(3).map((r) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _HealthRecordTile(record: r)
                  .animate()
                  .fadeIn(delay: 450.ms, duration: 300.ms),
            );
          }),
        ],
      ),
    );
  }
}

class _Service {
  final String iconAsset;
  final String title;
  final String subtitle;
  const _Service(
      {required this.iconAsset, required this.title, required this.subtitle});
}

class _ServiceTile extends StatelessWidget {
  final _Service service;
  final VoidCallback? onTap;

  const _ServiceTile({required this.service, this.onTap});

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
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.medicalBlue.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  service.iconAsset,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.title, style: AppTextStyles.labelLarge),
                  Text(service.subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: AppColors.textDimmed, size: 20),
          ],
        ),
      ),
    );
  }
}

class _HealthRecordTile extends StatelessWidget {
  final HealthRecord record;
  const _HealthRecordTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final isNormal = record.status == 'Normal' || record.status == 'Good';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                Text(record.type, style: AppTextStyles.labelLarge),
                Text(record.date, style: AppTextStyles.caption),
              ],
            ),
          ),
          Text(record.value, style: AppTextStyles.bodySmall),
          const SizedBox(width: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (isNormal ? AppColors.successGreen : AppColors.alertRed)
                  .withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              record.status,
              style: AppTextStyles.caption.copyWith(
                color: isNormal
                    ? AppColors.successGreen
                    : AppColors.alertRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
