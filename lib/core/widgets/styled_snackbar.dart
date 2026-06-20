import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

void _showStyledSnackBar(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 3),
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onBrand),
      ),
      backgroundColor: AppColors.snackbarBackground,
      behavior: SnackBarBehavior.floating,
      duration: duration,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      action: (actionLabel != null && onAction != null)
          ? SnackBarAction(
              label: actionLabel,
              textColor: AppColors.brand,
              onPressed: onAction,
            )
          : null,
    ),
  );
}

/// Success-style SnackBar: dark background, white text, 8dp radius, 3s, floating.
void showSuccessSnackBar(BuildContext context, String message) {
  _showStyledSnackBar(context, message);
}

/// Info-style SnackBar for non-error notices such as session expiry.
void showInfoSnackBar(BuildContext context, String message) {
  _showStyledSnackBar(
    context,
    message,
    duration: const Duration(seconds: 4),
  );
}

/// Error-style SnackBar: dark background, white text, 8dp radius,
/// 3s duration, floating, optional action in brand blue.
void showErrorSnackBar(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
}) {
  _showStyledSnackBar(
    context,
    message,
    actionLabel: actionLabel,
    onAction: onAction,
  );
}
