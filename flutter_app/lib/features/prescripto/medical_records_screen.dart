import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class MedicalRecordsScreen extends StatelessWidget {
  const MedicalRecordsScreen({super.key});

  static const List<Map<String, String>> _records = [
    {
      'doctor': 'Dr. Anjali Sharma',
      'specialty': 'General Physician',
      'date': '20 Jun 2026',
      'time': '10:30 AM',
      'image': 'assets/images/Prescription1.jpeg',
    },
    {
      'doctor': 'Dr. Rahul Verma',
      'specialty': 'Cardiology',
      'date': '18 Jun 2026',
      'time': '02:15 PM',
      'image': 'assets/images/Prescription2.jpg',
    },
    {
      'doctor': 'Dr. Neha Singh',
      'specialty': 'Dermatology',
      'date': '15 Jun 2026',
      'time': '11:00 AM',
      'image': 'assets/images/Prescription3.jpg',
    },
    {
      'doctor': 'Dr. Priya Nair',
      'specialty': 'Gynecology',
      'date': '10 Jun 2026',
      'time': '04:30 PM',
      'image': 'assets/images/Prescription4.jpg',
    },
    {
      'doctor': 'Dr. Vikram Mehta',
      'specialty': 'Neurology',
      'date': '05 Jun 2026',
      'time': '09:00 AM',
      'image': 'assets/images/Prescription5.png',
    },
    {
      'doctor': 'Dr. Sanjay Dutt',
      'specialty': 'Psychiatry',
      'date': '01 Jun 2026',
      'time': '12:00 PM',
      'image': 'assets/images/Prescription6.png',
    },
  ];

  void _viewPrescription(BuildContext context, String imagePath, String doctorName) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.95),
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.close, color: AppColors.textWhite, size: 28),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Prescription - $doctorName',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textWhite, fontWeight: FontWeight.bold),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              clipBehavior: Clip.none,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textWhite, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text('Medical Records', style: AppTextStyles.appBarTitle),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _records.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final record = _records[i];
          return GestureDetector(
            onTap: () => _viewPrescription(context, record['image']!, record['doctor']!),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.medicalBlue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(Icons.receipt_long, color: AppColors.medicalBlue, size: 24),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(record['doctor']!, style: AppTextStyles.labelLarge),
                        Text(record['specialty']!, style: AppTextStyles.bodySmall),
                        const SizedBox(height: 6),
                        Text('${record['date']} at ${record['time']}',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textDimmed)),
                      ],
                    ),
                  ),
                  Icon(Icons.open_in_full, color: AppColors.textDimmed, size: 18),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
