import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../core/services/auth_service.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../core/constants/app_strings.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    final ok = await ref.read(authStateProvider.notifier).register(
      _nameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (ok) {
      context.go(AppRoutes.home);
    } else {
      setState(() => _error = AuthService.instance.lastError ?? 'Registration failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
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

                Text(AppStrings.register, style: AppTextStyles.h1)
                    .animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 8),
                Text(AppStrings.joinMultiDomain, style: AppTextStyles.bodyMedium)
                    .animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 32),

                AppTextField(
                  hint: 'Enter your full name',
                  label: AppStrings.fullName,
                  controller: _nameCtrl,
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return 'Name required';
                    if (value.length < 2) return 'Enter your full name';
                    return null;
                  },
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 16),

                AppTextField(
                  hint: 'Enter your email',
                  label: AppStrings.email,
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return 'Email required';
                    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
                      return AppStrings.invalidEmail;
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 280.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 16),

                AppTextField(
                  hint: 'Create a password',
                  label: AppStrings.password,
                  controller: _passwordCtrl,
                  isPassword: true,
                  validator: (v) {
                    final value = v ?? '';
                    if (value.length < 8) return 'Min 8 characters';
                    if (!RegExp(r'[A-Za-z]').hasMatch(value) || !RegExp(r'\d').hasMatch(value)) {
                      return 'Use at least one letter and one number';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 360.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 28),

                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.alertRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.alertRed.withOpacity(0.3)),
                    ),
                    child: Text(
                      _error!,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.alertRed),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                AppButton(
                  label: AppStrings.signUp,
                  isLoading: _isLoading,
                  onPressed: _register,
                ).animate().fadeIn(delay: 440.ms),

                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(AppStrings.orContinueWith, style: AppTextStyles.caption),
                    ),
                    Expanded(child: Divider(color: AppColors.border)),
                  ],
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 20),

                Row(
                  children: [
                    SocialButton(emoji: 'G', label: 'Google', onPressed: () async {
	                      setState(() { _isLoading = true; _error = null; });
	                      final ok = await ref.read(authStateProvider.notifier).loginWithGoogle();
	                      if (!context.mounted) return;
	                      setState(() => _isLoading = false);
                      if (ok) {
                        context.go(AppRoutes.home);
                      } else {
                        setState(() => _error = AuthService.instance.lastError ?? 'Google Sign-In failed.');
                      }
                    }),
                    const SizedBox(width: 12),
                    SocialButton(imagePath: 'assets/images/apple_logo.png', label: 'Apple', onPressed: () {}),
                  ],
                ).animate().fadeIn(delay: 560.ms),

                const SizedBox(height: 32),

                Center(
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: RichText(
                      text: TextSpan(
                        text: AppStrings.alreadyHaveAccount,
                        style: AppTextStyles.bodyMedium,
                        children: [
                          TextSpan(
                            text: AppStrings.login,
                            style: AppTextStyles.labelLarge
                                .copyWith(color: AppColors.secondaryPurple),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 620.ms),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
