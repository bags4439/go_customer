import 'package:flutter/material.dart';

import '../theme/app_button_styles.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// Standard brand-filled CTA. Uses [AppButtonStyles.primary] — no inline hex.
///
/// Prefer this (or a plain [FilledButton] with no style override) for primary
/// actions. Pass [isLoading] to show an inline spinner without changing colour.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.fullWidth = true,
    this.height = 48,
    this.textStyle,
    this.prominent = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final bool fullWidth;
  final double height;
  final TextStyle? textStyle;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final canTap = enabled && !isLoading && onPressed != null;

    final button = FilledButton(
      onPressed: canTap ? onPressed : null,
      style: isLoading
          ? AppButtonStyles.primaryLoading(minimumHeight: height)
          : AppButtonStyles.primary(
              enabled: enabled && onPressed != null,
              minimumHeight: height,
            ),
      child: isLoading
          ? SizedBox(
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
    );

    Widget result = button;
    if (prominent && canTap) {
      result = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppTheme.pillBorderRadius(height),
          boxShadow: const [
            BoxShadow(
              color: AppColors.brandShadow,
              blurRadius: 14,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: result,
      );
    }

    if (!fullWidth) return result;
    return SizedBox(width: double.infinity, height: height, child: result);
  }
}
