import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock/safeguard_mock.dart';
import '../../shared/widgets/app_button.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _sirenCtrl;
  
  bool _isCountdownActive = false;
  bool _isAlertActive = false;
  int _countdownSeconds = 3;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: false);

    _sirenCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _sirenCtrl.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startSosCountdown() {
    setState(() {
      _isCountdownActive = true;
      _countdownSeconds = 3;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds == 1) {
        timer.cancel();
        _triggerSosAlert();
      } else {
        setState(() {
          _countdownSeconds--;
        });
      }
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _isCountdownActive = false;
    });
  }

  void _triggerSosAlert() {
    setState(() {
      _isCountdownActive = false;
      _isAlertActive = true;
    });
    _sirenCtrl.repeat(reverse: true);
  }

  void _stopSosAlert() {
    _sirenCtrl.stop();
    setState(() {
      _isAlertActive = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.successGreen,
        content: Text('SOS Alert deactivated. Contacts notified that you are safe.',
            style: AppTextStyles.labelLarge),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sirenCtrl,
      builder: (context, child) {
        // Flashing red/blue siren glow in background when alert active
        final sirenVal = _sirenCtrl.value;
        final bgColor = _isAlertActive
            ? Color.lerp(
                const Color(0xFF1E0303),
                const Color(0xFF030D2E),
                sirenVal,
              )
            : AppColors.background;

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Header
                  Row(
                    children: [
                      Text(
                        _isAlertActive ? 'SOS ACTIVE' : 'SOS Alert',
                        style: AppTextStyles.h1.copyWith(
                          color: _isAlertActive ? AppColors.alertRed : AppColors.textWhite,
                        ),
                      ),
                      const Spacer(),
                      if (!_isAlertActive && !_isCountdownActive)
                        IconButton(
                          icon: Icon(Icons.close, color: AppColors.textGray),
                          onPressed: () => context.pop(),
                        ),
                    ],
                  ).animate().fadeIn(duration: 300.ms),

                  const Spacer(),

                  // Interactive Main Section
                  _buildInteractiveCenter(),

                  const Spacer(),

                  // Info Cards
                  if (!_isCountdownActive && !_isAlertActive) ...[
                    // Location card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: AppColors.alertRed, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Your Current Location', style: AppTextStyles.labelMedium),
                                const SizedBox(height: 2),
                                Text(
                                  '$mockUserLocation ($mockUserCoordinates)',
                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGray),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.successGreen.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'GPS Active',
                              style: AppTextStyles.caption.copyWith(color: AppColors.successGreen),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 14),

                    // Contacts Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.people_alt_outlined, color: AppColors.secondaryPurple, size: 24),
                          const SizedBox(width: 12),
                          Text('Sharing alerts with ', style: AppTextStyles.bodyMedium),
                          Text(
                            '$mockShareWithCount Contacts',
                            style: AppTextStyles.labelLarge.copyWith(color: AppColors.secondaryPurple),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1, end: 0),
                  ],

                  if (_isCountdownActive) ...[
                    Text(
                      'Press to Cancel',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGray),
                    ).animate().fadeIn().shake(),
                    const SizedBox(height: 20),
                    AppButton(
                      label: 'Cancel Trigger',
                      gradientColors: [Colors.grey[850]!, Colors.grey[800]!],
                      onPressed: _cancelCountdown,
                    ),
                  ],

                  if (_isAlertActive) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.alertRed.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.alertRed.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.warning, color: AppColors.alertRed, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'EMERGENCY IN PROGRESS',
                                style: AppTextStyles.labelLarge.copyWith(color: AppColors.alertRed, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sent location coordinates ($mockUserCoordinates) and help request messages to all registered emergency contacts.',
                            style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ).animate().fadeIn().scale(),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'I AM SAFE NOW (Stop SOS)',
                      gradientColors: [AppColors.successGreen, AppColors.successGreen],
                      onPressed: _stopSosAlert,
                    ),
                  ],

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInteractiveCenter() {
    if (_isCountdownActive) {
      return AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (context, child) {
          final scale = 1.0 + (_pulseCtrl.value * 0.15);
          return Column(
            children: [
              Text('SENDING SOS IN', style: AppTextStyles.h3.copyWith(color: AppColors.alertRed, letterSpacing: 1.5)),
              const SizedBox(height: 30),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 180 * scale,
                    height: 180 * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.alertRed.withOpacity(0.15),
                    ),
                  ),
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.alertRed,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.alertRed.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$_countdownSeconds',
                        style: const TextStyle(fontSize: 64, color: Colors.white, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    }

    if (_isAlertActive) {
      return AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (context, child) {
          final scale1 = 1.0 + (_pulseCtrl.value * 0.3);
          final scale2 = 1.0 + (_pulseCtrl.value * 0.6);
          return Column(
            children: [
              Text('EMERGENCY BROADCAST ACTIVE', style: AppTextStyles.h3.copyWith(color: AppColors.alertRed, letterSpacing: 1.5)),
              const SizedBox(height: 35),
              Stack(
                alignment: Alignment.center,
                children: [
                  // Sonar rings
                  Container(
                    width: 220 * scale2,
                    height: 220 * scale2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.alertRed.withOpacity(0.15 * (1.0 - _pulseCtrl.value)), width: 3),
                    ),
                  ),
                  Container(
                    width: 180 * scale1,
                    height: 180 * scale1,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.alertRed.withOpacity(0.4 * (1.0 - _pulseCtrl.value)), width: 2),
                    ),
                  ),
                  // Flashing button
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.alertRed,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.alertRed,
                          blurRadius: 40 * _pulseCtrl.value,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.emergency, color: Colors.white, size: 40).animate(onPlay: (c) => c.repeat()).shake(hz: 8),
                          const SizedBox(height: 4),
                          Text(
                            'SIREN ON',
                            style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    }

    // Default "Tap to Send" State
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (context, child) {
        final scale1 = 1.0 + (_pulseCtrl.value * 0.15);
        final scale2 = 1.0 + (_pulseCtrl.value * 0.3);

        return Stack(
          alignment: Alignment.center,
          children: [
            // Sonar radar rings
            Container(
              width: 200 * scale2,
              height: 200 * scale2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.alertRed.withOpacity(0.15 * (1.0 - _pulseCtrl.value)),
                  width: 2,
                ),
              ),
            ),
            Container(
              width: 160 * scale1,
              height: 160 * scale1,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.alertRed.withOpacity(0.3 * (1.0 - _pulseCtrl.value)),
                  width: 2,
                ),
              ),
            ),
            // Glowing main trigger button
            GestureDetector(
              onTap: _startSosCountdown,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: AppColors.alertRed,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.alertRed.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SOS',
                      style: AppTextStyles.displayLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Tap to Send Alert',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ).animate().scale(
          begin: const Offset(0.8, 0.8),
          duration: 600.ms,
          curve: Curves.elasticOut,
        );
  }
}
