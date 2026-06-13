import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_theme.dart';

/// Shared [ButtonStyle] factories — prefer these over inline `styleFrom`.
///
/// Default Material buttons ([FilledButton], etc.) already inherit matching
/// styles from [AppTheme.light]. Use this class when a widget needs an
/// explicit override (disabled, destructive, inverse, success, compact).
class AppButtonStyles {
  AppButtonStyles._();

  static ButtonStyle primary({
    bool enabled = true,
    double? minimumHeight,
    OutlinedBorder? shape,
    Size? minimumSize,
    Color? disabledBackgroundColor,
  }) {
    return FilledButton.styleFrom(
      backgroundColor: enabled ? AppColors.brand : AppColors.borderSolid,
      foregroundColor: enabled ? AppColors.onBrand : AppColors.textTertiary,
      disabledBackgroundColor:
          disabledBackgroundColor ?? AppColors.borderSolid,
      disabledForegroundColor: AppColors.textTertiary,
      elevation: 0,
      shape: shape ?? AppTheme.buttonPillShape,
      minimumSize: minimumSize ??
          Size(
            AppTheme.buttonMinimumSize.width,
            minimumHeight ?? AppTheme.buttonMinimumSize.height,
          ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    );
  }

  static ButtonStyle primaryLoading({double? minimumHeight}) {
    return primary(enabled: true, minimumHeight: minimumHeight).copyWith(
      backgroundColor: const WidgetStatePropertyAll(AppColors.brand),
      foregroundColor: const WidgetStatePropertyAll(AppColors.onBrand),
    );
  }

  /// White fill on brand surfaces (e.g. payment hero cards).
  static ButtonStyle inversePrimary({
    double? minimumHeight,
    OutlinedBorder? shape,
  }) {
    return FilledButton.styleFrom(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.brand,
      elevation: 0,
      shape: shape ?? AppTheme.buttonPillShape,
      minimumSize: Size(
        AppTheme.buttonMinimumSize.width,
        minimumHeight ?? 44,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    );
  }

  static ButtonStyle outlined({Color? foregroundColor, OutlinedBorder? shape}) {
    return OutlinedButton.styleFrom(
      foregroundColor: foregroundColor ?? AppColors.foreground,
      side: const BorderSide(color: AppColors.borderSolid),
      shape: shape ?? AppTheme.buttonPillShape,
      minimumSize: AppTheme.buttonMinimumSize,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    );
  }

  static ButtonStyle outlinedBrand({double? minimumHeight}) {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.brand,
      side: const BorderSide(color: AppColors.brand),
      shape: AppTheme.buttonPillShape,
      minimumSize: Size(0, minimumHeight ?? AppTheme.buttonMinimumSize.height),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  static ButtonStyle text() {
    return TextButton.styleFrom(
      foregroundColor: AppColors.brand,
      shape: AppTheme.buttonPillShape,
      minimumSize: AppTheme.buttonMinimumSize,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  static ButtonStyle destructive({
    bool enabled = true,
    OutlinedBorder? shape,
    double? minimumHeight,
  }) {
    return FilledButton.styleFrom(
      backgroundColor: enabled ? AppColors.danger : AppColors.textTertiary,
      foregroundColor: AppColors.onBrand,
      disabledBackgroundColor: AppColors.textTertiary,
      disabledForegroundColor: AppColors.onBrand,
      elevation: 0,
      shape: shape ?? AppTheme.buttonPillShape,
      minimumSize: Size(
        AppTheme.buttonMinimumSize.width,
        minimumHeight ?? AppTheme.buttonMinimumSize.height,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    );
  }

  /// Delivery confirmation and other success CTAs.
  static ButtonStyle success({
    double? minimumHeight,
    bool enabled = true,
  }) {
    return FilledButton.styleFrom(
      backgroundColor: enabled ? AppColors.success : AppColors.borderSolid,
      foregroundColor: AppColors.onBrand,
      disabledBackgroundColor: AppColors.borderSolid,
      disabledForegroundColor: AppColors.textTertiary,
      elevation: 0,
      shape: AppTheme.buttonPillShape,
      minimumSize: Size(
        double.infinity,
        minimumHeight ?? 52,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    );
  }

  /// Compact inline brand CTA (e.g. payment row actions).
  static ButtonStyle compactBrand() {
    return FilledButton.styleFrom(
      backgroundColor: AppColors.brand,
      foregroundColor: AppColors.onBrand,
      elevation: 0,
      shape: AppTheme.buttonPillShape,
      minimumSize: const Size(72, 40),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  /// Onboarding slides use per-slide accent colours.
  static ButtonStyle accentFill(
    Color accentColor, {
    double minimumHeight = 48,
  }) {
    return FilledButton.styleFrom(
      backgroundColor: accentColor,
      foregroundColor: AppColors.onBrand,
      elevation: 0,
      shape: AppTheme.buttonPillShape,
      minimumSize: Size(double.infinity, minimumHeight),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    );
  }

  /// Timeline / card actions with a dynamic background colour.
  static ButtonStyle filledColor(
    Color backgroundColor, {
    double minimumHeight = 48,
    Size? minimumSize,
  }) {
    return FilledButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: AppColors.onBrand,
      elevation: 0,
      shape: AppTheme.buttonPillShape,
      minimumSize: minimumSize ?? Size(double.infinity, minimumHeight),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    );
  }

  /// Vehicle-option timeline pill CTA.
  static ButtonStyle timelinePill({double minimumHeight = 48}) {
    return FilledButton.styleFrom(
      backgroundColor: AppColors.brand,
      foregroundColor: AppColors.onBrand,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      minimumSize: Size(0, minimumHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  static const BorderRadius mdShape = BorderRadius.all(
    Radius.circular(AppTheme.radiusLg),
  );

  static OutlinedBorder roundedMdShape = RoundedRectangleBorder(
    borderRadius: mdShape,
  );
}
