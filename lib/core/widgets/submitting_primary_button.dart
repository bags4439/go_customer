import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Primary CTA with disabled + inline spinner while [isSubmitting].
/// Keeps the active colour when a selection exists so the spinner stays visible.
class SubmittingPrimaryButton extends StatelessWidget {
  const SubmittingPrimaryButton({
    super.key,
    required this.label,
    required this.hasSelection,
    required this.isSubmitting,
    required this.onPressed,
    this.textStyle,
  });

  final String label;
  final bool hasSelection;
  final bool isSubmitting;
  final VoidCallback? onPressed;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: hasSelection && !isSubmitting ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              hasSelection ? AppColors.secondary : AppColors.surface,
          foregroundColor:
              hasSelection ? Colors.white : AppColors.textTertiary,
          disabledBackgroundColor:
              hasSelection ? AppColors.secondary : AppColors.surface,
          disabledForegroundColor:
              hasSelection ? Colors.white : AppColors.textTertiary,
          elevation: 0,
          minimumSize: const Size(double.infinity, 48),
        ),
        child: isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: textStyle ?? AppTextStyles.buttonLarge,
              ),
      ),
    );
  }
}
