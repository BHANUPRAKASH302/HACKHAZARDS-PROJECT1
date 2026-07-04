import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Styled text input field matching the design system.
class AppTextField extends StatefulWidget {
  final String hint;
  final String? label;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefix;
  final Widget? suffix;
  final bool readOnly;
  final VoidCallback? onTap;
  final void Function(String)? onChanged;
  final int maxLines;
  final TextInputAction textInputAction;

  const AppTextField({
    super.key,
    required this.hint,
    this.label,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefix,
    this.suffix,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.maxLines = 1,
    this.textInputAction = TextInputAction.next,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: AppTextStyles.labelMedium),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscure,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          textInputAction: widget.textInputAction,
          style: AppTextStyles.bodyLarge,
          cursorColor: AppColors.primaryPurple,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefix != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: widget.prefix,
                  )
                : null,
            prefixIconConstraints:
                const BoxConstraints(minWidth: 44, minHeight: 44),
            suffixIcon: widget.isPassword
                ? IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textDimmed,
                      size: 20,
                    ),
                  )
                : widget.suffix != null
                    ? Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: widget.suffix,
                      )
                    : null,
          ),
        ),
      ],
    );
  }
}
