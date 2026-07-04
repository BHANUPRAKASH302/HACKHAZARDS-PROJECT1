import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Primary gradient button used across the app.
/// Supports loading state and custom gradient.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final List<Color>? gradientColors;
  final double height;
  final Widget? prefix;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.gradientColors,
    this.height = 52,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return SizedBox(
        height: height,
        width: double.infinity,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.border, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _buildChild(),
        ),
      );
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors ??
                    [AppColors.primaryPurple, AppColors.secondaryPurple],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(child: _buildChild()),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2.5,
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (prefix != null) ...[prefix!, const SizedBox(width: 8)],
        Text(label, style: AppTextStyles.buttonText),
      ],
    );
  }
}

/// Social icon button (Google, Apple).
class SocialButton extends StatelessWidget {
  final String label;
  final String? emoji;
  final String? imagePath;
  final VoidCallback? onPressed;

  const SocialButton({
    super.key,
    required this.label,
    this.emoji,
    this.imagePath,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (emoji != null) Text(emoji!, style: const TextStyle(fontSize: 18)),
              if (imagePath != null) Image.asset(imagePath!, width: 20, height: 20),
              if (emoji != null || imagePath != null) const SizedBox(width: 8),
              Text(label, style: AppTextStyles.labelLarge),
            ],
          ),
        ),
      ),
    );
  }
}
