import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Centralised text styles for the customer app. All styles use DM Sans.
/// Changing the font app-wide requires updating only this file.
///
/// Usage:
///   Text('Hello', style: AppTextStyles.titleMedium)
///
///   Text('Muted',
///     style: AppTextStyles.bodySmall
///       .copyWith(color: AppColors.success))
class AppTextStyles {
  AppTextStyles._();

  // ─── Display ─────────────────────
  // Hero numbers, large impact moments

  static TextStyle get displayLarge => GoogleFonts.dmSans(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get displayMedium => GoogleFonts.dmSans(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        color: AppColors.textPrimary,
      );

  static TextStyle get displaySmall => GoogleFonts.dmSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  // ─── Titles ──────────────────────
  // Screen titles, card headings

  static TextStyle get titleLarge => GoogleFonts.dmSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleMedium => GoogleFonts.dmSans(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleSmall => GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  // ─── Body ────────────────────────
  // Paragraph text, descriptions

  static TextStyle get bodyLarge => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.55,
      );

  static TextStyle get bodyMedium => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  // ─── Labels ──────────────────────
  // UI labels, tags, form labels

  static TextStyle get labelLarge => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        letterSpacing: 0.2,
      );

  static TextStyle get labelSmall => GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 0.3,
      );

  // ─── Section labels ──────────────
  // "VESSEL DETAILS", "DUTY BREAKDOWN"
  // All-caps section headers

  static TextStyle get sectionLabel => GoogleFonts.dmSans(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.textTertiary,
        letterSpacing: 0.8,
      );

  // ─── Card text ───────────────────
  // Detail rows in info cards

  static TextStyle get cardLabel => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get cardValue => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  // ─── Amounts ─────────────────────
  // Prices, totals, duty amounts

  static TextStyle get amountLarge => GoogleFonts.dmSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get amountMedium => GoogleFonts.dmSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get amountSmall => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiary,
      );

  // ─── Badge text ──────────────────
  // "AGENT NOTE", "ACTION REQUIRED"

  static TextStyle get badgeText => GoogleFonts.dmSans(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: AppColors.textTertiary,
        letterSpacing: 0.6,
      );

  // ─── Buttons ─────────────────────
  // Primary and secondary button labels

  static TextStyle get buttonLarge => GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.onBrand,
      );

  static TextStyle get buttonMedium => GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.onBrand,
      );

  // ─── Captions ────────────────────
  // Timestamps, metadata, helper text

  static TextStyle get caption => GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiary,
      );

  // ─── Links ───────────────────────
  // Tappable text links

  static TextStyle get link => GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.brand,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.brand,
      );

  // ─── AppBar title ─────────────────
  // Standard screen title in AppBar

  static TextStyle get appBarTitle => GoogleFonts.dmSans(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  // ─── Material TextTheme ───────────
  // Maps our styles to Material's TextTheme so AppTheme.light() continues
  // to work. Both systems now share the same source.

  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: displaySmall,
        headlineMedium: titleLarge,
        headlineSmall: titleLarge.copyWith(fontSize: 20),
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );
}
