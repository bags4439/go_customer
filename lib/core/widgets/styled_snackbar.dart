import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Success-style SnackBar: dark background, white text, 8dp radius, 3s, floating.
void showSuccessSnackBar(BuildContext context, String message) {
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
      duration: const Duration(seconds: 3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
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
      duration: const Duration(seconds: 3),
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
