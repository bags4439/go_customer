import 'package:flutter/material.dart';
import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

TextStyle homeTextStyle({
  double size = 13,
  FontWeight weight = FontWeight.w400,
  Color color = AppColors.textPrimary,
  double height = 1.4,
}) {
  return AppTextStyles.bodySmall.copyWith(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );
}
