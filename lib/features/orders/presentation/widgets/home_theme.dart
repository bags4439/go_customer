import 'package:flutter/material.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

/// Local palette for home dashboard widgets.
abstract final class HomeColors {
  static const primary = Color(0xFF378ADD);
  static const success = Color(0xFF1D9E75);
  static const danger = Color(0xFFE24B4A);
  static const warning = Color(0xFFBA7517);
  static const bgPrimary = Color(0xFFFFFFFF);
  static const bgSecondary = Color(0xFFF5F4F0);
  static const border = Color(0xFFE0DFD8);
  static const textPrimary = Color(0xFF1A1A18);
  static const textSecondary = Color(0xFF666666);
  static const textTertiary = Color(0xFFAAAAAA);
  static const infoBg = Color(0xFFE6F1FB);
  static const infoText = Color(0xFF185FA5);
  static const successBg = Color(0xFFEAF3DE);
  static const dangerBg = Color(0xFFFCEBEB);
  static const warningBg = Color(0xFFFAEEDA);
  static const pillSoftBlue = Color(0xFFEBF4FD);
  static const amberText = Color(0xFF633806);
  static const successMutedForeground = Color(0xFF27500A);
}

TextStyle homeTextStyle({
  double size = 13,
  FontWeight weight = FontWeight.w400,
  Color color = HomeColors.textPrimary,
  double height = 1.4,
}) {
  return AppTextStyles.bodySmall.copyWith(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );
}
