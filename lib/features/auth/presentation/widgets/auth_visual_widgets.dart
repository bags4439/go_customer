import 'package:flutter/material.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';
import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/core/widgets/app_logo.dart';

/// Text-based logo for auth flows (DM Sans; primary mark per design spec).
class AuthAppLogo extends StatelessWidget {
  final double fontSize;

  const AuthAppLogo({super.key, this.fontSize = 26});

  @override
  Widget build(BuildContext context) {
    return AppLogo(fontSize: fontSize, style: AppLogoStyle.standard);
  }
}

class AuthFormFieldLabel extends StatelessWidget {
  final String label;

  const AuthFormFieldLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelSmall.copyWith(
        color: AppColors.textTertiary,
        letterSpacing: 11 * 0.08,
      ),
    );
  }
}

/// Bordered text field matching auth screens (animated focus / error).
class StyledAuthTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final bool focused;
  final bool hasError;

  const StyledAuthTextField({
    super.key,
    this.controller,
    this.focusNode,
    required this.hintText,
    this.onChanged,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    required this.focused,
    this.hasError = false,
  });


  @override
  Widget build(BuildContext context) {
    final borderColor = hasError
        ? AppColors.danger
        : (focused ? AppColors.brand : AppColors.borderSolid);
    final borderWidth = hasError || focused ? 1.5 : 1.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor, width: borderWidth),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        textInputAction: textInputAction,
        style: AppTextStyles.bodyLarge.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: null,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.bodyLarge.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.textTertiary,
            height: null,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}

void showAuthSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.textPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      duration: const Duration(seconds: 3),
      content: Text(
        message,
        style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
      ),
    ),
  );
}
