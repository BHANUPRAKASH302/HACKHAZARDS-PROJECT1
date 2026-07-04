import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class MedicinesScreen extends StatefulWidget {
  const MedicinesScreen({super.key});

  @override
  State<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  final List<Map<String, dynamic>> _medicines = [
    {
      'id': 'med_1',
      'name': 'Paracetamol',
      'dosage': '1 tablet after meals (SOS / As needed)',
      'image': 'assets/images/paracetamol.jpg',
      'schedule': 'Mon, Wed, Fri',
    },
    {
      'id': 'med_2',
      'name': 'Metformin',
      'dosage': '1 tablet (Twice daily, with meals)',
      'image': 'assets/images/metformin.jpg',
      'schedule': 'Daily (Mon to Sun)',
    },
    {
      'id': 'med_3',
      'name': 'Amoxicillin',
      'dosage': '1 capsule (Three times daily, 5-day course)',
      'image': 'assets/images/Amoxicillin.jpg',
      'schedule': 'Mon to Fri',
    },
    {
      'id': 'med_4',
      'name': 'Pantoprazole',
      'dosage': '1 tablet (Before breakfast)',
      'image': 'assets/images/Pantoprazole.webp',
      'schedule': 'Daily (Mon to Sun)',
    },
    {
      'id': 'med_5',
      'name': 'Cetirizine',
      'dosage': '1 tablet (At night, as needed)',
      'image': 'assets/images/Cetirizine.jpg',
      'schedule': 'Mon, Wed, Sat',
    },
    {
      'id': 'med_6',
      'name': 'Amlodipine',
      'dosage': '1 tablet (Every morning)',
      'image': 'assets/images/Amlodipine.jpeg',
      'schedule': 'Daily (Mon to Sun)',
    },
  ];

  final List<String> _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  final Map<String, List<bool>> _dosageLogs = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    for (final med in _medicines) {
      final key = 'dosage_log_${med['id']}';
      final savedStr = prefs.getStringList(key);
      if (savedStr != null && savedStr.length == 7) {
        _dosageLogs[med['id']] = savedStr.map((val) => val == 'true').toList();
      } else {
        _dosageLogs[med['id']] = List.generate(7, (_) => false);
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _toggleDay(String medId, int dayIndex) async {
    setState(() {
      _dosageLogs[medId]![dayIndex] = !_dosageLogs[medId]![dayIndex];
    });

    final prefs = await SharedPreferences.getInstance();
    final key = 'dosage_log_$medId';
    final saveVal = _dosageLogs[medId]!.map((val) => val.toString()).toList();
    await prefs.setStringList(key, saveVal);
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
        title: Text('Weekly Dosage Tracker', style: AppTextStyles.appBarTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.medicalBlue))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _medicines.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (ctx, index) {
                final med = _medicines[index];
                final logs = _dosageLogs[med['id']] ?? List.generate(7, (_) => false);

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Medicine Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              med['image']!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(med['name']!, style: AppTextStyles.labelLarge),
                                const SizedBox(height: 4),
                                Text(med['dosage']!, style: AppTextStyles.bodySmall),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.schedule, color: AppColors.medicalBlue, size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      med['schedule']!,
                                      style: AppTextStyles.caption.copyWith(color: AppColors.medicalBlue),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(color: AppColors.border, height: 24),
                      Text(
                        'Tap weekdays to mark as taken:',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textDimmed),
                      ),
                      const SizedBox(height: 8),
                      // Row of Interactive Weekday Toggle circles
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (i) {
                          final isTaken = logs[i];
                          return GestureDetector(
                            onTap: () => _toggleDay(med['id']!, i),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isTaken ? AppColors.successGreen : AppColors.background,
                                border: Border.all(
                                  color: isTaken ? AppColors.successGreen : AppColors.border,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _weekdays[i],
                                  style: AppTextStyles.caption.copyWith(
                                    color: isTaken ? AppColors.textWhite : AppColors.textDimmed,
                                    fontWeight: isTaken ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
