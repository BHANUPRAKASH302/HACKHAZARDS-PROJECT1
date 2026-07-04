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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    final ok = await ref.read(authStateProvider.notifier).login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (ok) {
      context.go(AppRoutes.home);
    } else {
      setState(() => _error = AuthService.instance.lastError ?? AppStrings.invalidCredentials);
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailCtrl = TextEditingController(text: _emailCtrl.text.trim());
    final tokenCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String? dialogMessage;
    bool resetRequested = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(AppStrings.forgotPassword, style: AppTextStyles.h2),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: AppTextStyles.bodyMedium,
                  decoration: _dialogInputDecoration(AppStrings.email),
                ),
                if (resetRequested) ...[
                  const SizedBox(height: 14),
                  TextField(
                    controller: tokenCtrl,
                    style: AppTextStyles.bodyMedium,
                    decoration: _dialogInputDecoration('Reset token'),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: passwordCtrl,
                    obscureText: true,
                    style: AppTextStyles.bodyMedium,
                    decoration: _dialogInputDecoration('New password'),
                  ),
                ],
                if (dialogMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(dialogMessage!, style: AppTextStyles.bodySmall),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: AppTextStyles.bodyMedium),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple),
              onPressed: () async {
                if (!resetRequested) {
                  final resetToken = await AuthService.instance.requestPasswordReset(emailCtrl.text);
                  setDialogState(() {
                    resetRequested = true;
                    if (resetToken != null) tokenCtrl.text = resetToken;
                    dialogMessage = resetToken == null
                        ? 'If the account exists, reset instructions are ready.'
                        : 'Development reset token generated. Use it below.';
                  });
                  return;
                }

                final ok = await AuthService.instance.resetPassword(
                  tokenCtrl.text,
                  passwordCtrl.text,
                );
                if (!ctx.mounted) return;
                if (ok) {
                  Navigator.pop(ctx);
                  setState(() => _error = 'Password updated. You can log in now.');
                } else {
                  setDialogState(() {
                    dialogMessage = AuthService.instance.lastError ?? 'Password reset failed.';
                  });
                }
              },
              child: Text(
                resetRequested ? 'Reset Password' : 'Send Reset',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _dialogInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.labelLarge,
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primaryPurple)),
    );
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

                // Back
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

                Text(AppStrings.welcomeBack, style: AppTextStyles.h1)
                    .animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 8),

                Text('Login to continue', style: AppTextStyles.bodyMedium)
                    .animate().fadeIn(delay: 100.ms, duration: 400.ms),

                const SizedBox(height: 32),

                // Email
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
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 16),

                // Password
                AppTextField(
                  hint: 'Enter your password',
                  label: AppStrings.password,
                  controller: _passwordCtrl,
                  isPassword: true,
                  validator: (v) => v == null || v.isEmpty ? 'Password required' : null,
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 12),

                // Forgot
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPasswordDialog,
                    child: Text(AppStrings.forgotPassword,
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.secondaryPurple)),
                  ),
                ).animate().fadeIn(delay: 350.ms),

                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.alertRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.alertRed.withOpacity(0.3)),
                    ),
                    child: Text(_error!,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.alertRed)),
                  ),
                ],

                const SizedBox(height: 24),

                AppButton(
                  label: AppStrings.login,
                  isLoading: _isLoading,
                  onPressed: _login,
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 28),

                // Divider
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
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 32),

                // Sign up
                Center(
                  child: GestureDetector(
                    onTap: () => context.push(AppRoutes.register),
                    child: RichText(
                      text: TextSpan(
                        text: AppStrings.dontHaveAccount,
                        style: AppTextStyles.bodyMedium,
                        children: [
                          TextSpan(
                            text: AppStrings.signUp,
                            style: AppTextStyles.labelLarge
                                .copyWith(color: AppColors.secondaryPurple),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 700.ms),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
