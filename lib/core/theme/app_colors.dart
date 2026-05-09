import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF000000); // black
  static const Color secondary = Color(
    0xFF378ADD,
  ); // blue — brand primary actions

  static const Color success = Color(0xFF1D9E75);
  static const Color warning = Color(0xFFBA7517);
  static const Color danger = Color(0xFFE24B4A);

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F4F0);

  static const Color border = Color(0x26000000); // rgba(0,0,0,0.15)
  static const Color borderSolid = Color(0xFFE0DFD8);

  static const Color textPrimary = Color(0xFF1A1A18);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFFAAAAAA);

  static const Color infoText = Color(0xFF185FA5);
  static const Color infoBackground = Color(0xFFE6F1FB);

  static const Color selectionTint = Color(0xFFEBF4FD);

  static const Color amberBackground = Color(0xFFFAEEDA);
  static const Color amberText = Color(0xFF633806);

  static const Color successMutedBackground = Color(0xFFEAF3DE);
  static const Color successMutedBorder = Color(0xFFC0DD97);
  static const Color successMutedForeground = Color(0xFF27500A);

  static const Color dangerMutedBackground = Color(0xFFFCEBEB);
  static const Color dangerMutedText = Color(0xFFA32D2D);

  /// Home referral promo card — horizontal gradient (brand blue family).
  static const Color referralCardGradientStart = Color(0xFF5FA3E5);
  static const Color referralCardGradientMid = secondary;
  static const Color referralCardGradientEnd = Color(0xFF2866A8);

  /// “Invite Friends” label on white pill (warning tone — on-brand emphasis).
  static const Color referralCtaLabel = warning;

  // ── Hover / interaction states ─

  /// Subtle hover background for
  /// nav items and interactive
  /// tiles on web. Slightly darker
  /// than surface.
  static const Color hoverSurface = Color(0xFFF0EFE9);

  /// Hover state for items that
  /// are already selected/active.
  static const Color hoverSelected = Color(0xFFD6E8F7);

  /// Panel shadow colour — used
  /// instead of hard dividers on
  /// web for a more premium feel.
  static const Color panelShadow = Color(0x0A000000);

  /// Background for secondary
  /// panels (timeline, selections
  /// summary) — very slightly off
  /// white to create depth.
  static const Color backgroundSecondary = Color(0xFFFAF9F7);
}
