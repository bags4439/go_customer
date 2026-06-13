import 'package:flutter/material.dart';

import '../theme/app_button_styles.dart';
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
      child: FilledButton(
        onPressed: hasSelection && !isSubmitting ? onPressed : null,
        style: hasSelection
            ? AppButtonStyles.primaryLoading()
            : AppButtonStyles.primary(enabled: false),
        child: isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.onBrand,
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
