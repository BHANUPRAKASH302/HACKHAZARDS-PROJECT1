import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/app_button.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  String _otp = '';
  bool _isLoading = false;
  int _resendSeconds = 30;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
        _startCountdown();
      }
    });
  }

  Future<void> _verify() async {
    if (_otp.length < 6) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isLoading = false);
    context.go(AppRoutes.home);
  }

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
                "We've sent your sign-in code to\n+91 86975 43210",
                style: AppTextStyles.bodyMedium,
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 40),

              // OTP field
              PinCodeTextField(
                appContext: context,
                length: 6,
                onChanged: (v) => setState(() => _otp = v),
                onCompleted: (_) => _verify(),
                autoFocus: true,
                keyboardType: TextInputType.number,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10),
                  fieldHeight: 52,
                  fieldWidth: 46,
                  activeFillColor: AppColors.card,
                  inactiveFillColor: AppColors.inputFill,
                  selectedFillColor: AppColors.card,
                  activeColor: AppColors.primaryPurple,
                  inactiveColor: AppColors.border,
                  selectedColor: AppColors.secondaryPurple,
                ),
                enableActiveFill: true,
                textStyle: AppTextStyles.h2,
                cursorColor: AppColors.primaryPurple,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 16),

              // Resend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Resend code in ', style: AppTextStyles.bodySmall),
                  Text(
                    '${_resendSeconds}s',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.secondaryPurple),
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 8),

              Center(
                child: TextButton(
                  onPressed: _resendSeconds == 0
                      ? () => setState(() => _resendSeconds = 30)
                      : null,
                  child: Text(
                    'Try another method',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: _resendSeconds == 0
                          ? AppColors.secondaryPurple
                          : AppColors.textDimmed,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms),

              const Spacer(),

              // Numpad hint
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: AppColors.secondaryPurple, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Verifying your account...\n(Enter any 6-digit code in demo mode)',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 20),

              AppButton(
                label: 'Verify & Continue',
                isLoading: _isLoading,
                onPressed: _otp.length == 6 ? _verify : null,
              ).animate().fadeIn(delay: 600.ms),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
