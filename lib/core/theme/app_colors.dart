import 'package:flutter/material.dart';

/// Single source of truth for all app colour literals.
///
/// Widgets must reference tokens from this file — never `Color(0xFF…)` inline.
/// See [brand] / [foreground] for action vs text roles.
class AppColors {
  AppColors._();

  // ── Brand ────────────────────────────────────────────────────────────────

  /// Main action colour — primary CTAs, key links, active nav, progress.
  static const Color brand = Color(0xFF2563A8);

  /// Text and icons on [brand]-filled surfaces (buttons, badges).
  static const Color onBrand = Color(0xFFFFFFFF);

  /// Supporting accent blue — info chips, filter pills, secondary emphasis.
  static const Color accent = Color(0xFF185FA5);

  /// Soft brand tint — selection backgrounds, hover on active items.
  static const Color brandMuted = Color(0xFFEBF4FD);

  /// Brand glow for elevated custom buttons (≈30% alpha).
  static const Color brandShadow = Color(0x4D378ADD);

  /// Deep brand navy for marketing / dark split panels.
  static const Color brandDeep = Color(0xFF042C53);

  /// Mid brand navy for panel headers on dark marketing surfaces.
  static const Color brandPanel = Color(0xFF0C447C);

  /// Snackbar inverse surface (dark toast background).
  static const Color snackbarBackground = textPrimary;

  // ── Legacy aliases (Phase 1 — keep until call sites migrate to [brand]) ──

  /// Material [ColorScheme.primary]. Same as [brand].
  static const Color primary = brand;

  /// Legacy action alias. Same as [brand] — do not use for body text.
  static const Color secondary = brand;

  /// Material [ColorScheme.onPrimary]. Same as [onBrand].
  static const Color onPrimary = onBrand;

  // ── Text / foreground ──────────────────────────────────────────────────────

  /// Primary reading text and strong UI chrome (titles, labels).
  static const Color foreground = textPrimary;

  static const Color textPrimary = Color(0xFF1A1A18);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFFAAAAAA);

  /// Muted metadata (order detail agent subtitle, de-emphasised labels).
  static const Color textMuted = Color(0xFF999999);

  // ── Semantic status ────────────────────────────────────────────────────────

  static const Color success = Color(0xFF1D9E75);
  static const Color warning = Color(0xFFBA7517);
  static const Color danger = Color(0xFFE24B4A);

  static const Color successMutedBackground = Color(0xFFEAF3DE);
  static const Color successMutedBorder = Color(0xFFC0DD97);
  static const Color successMutedForeground = Color(0xFF27500A);

  static const Color dangerMutedBackground = Color(0xFFFCEBEB);
  static const Color dangerMutedText = Color(0xFFA32D2D);

  static const Color amberBackground = Color(0xFFFAEEDA);
  static const Color amberText = Color(0xFF633806);

  // ── Info / filters ─────────────────────────────────────────────────────────

  static const Color infoText = accent;
  static const Color infoBackground = Color(0xFFE6F1FB);
  static const Color selectionTint = brandMuted;

  /// Active filter pill border (notifications, similar chips).
  static const Color filterActiveBorder = Color(0xFFB5D4F4);

  // ── Surfaces & borders ─────────────────────────────────────────────────────

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F4F0);
  static const Color backgroundSecondary = Color(0xFFFAF9F7);

  static const Color border = Color(0x26000000); // rgba(0,0,0,0.15)
  static const Color borderSolid = Color(0xFFE0DFD8);

  // ── Third-party ────────────────────────────────────────────────────────────

  static const Color whatsapp = Color(0xFF25D366);
  static const Color whatsappMuted = Color(0xFFECFDF5);

  // ── Referral gradient (brand blue family) ──────────────────────────────────

  static const Color referralCardGradientStart = Color(0xFF5FA3E5);
  static const Color referralCardGradientMid = brand;
  static const Color referralCardGradientEnd = Color(0xFF2866A8);

  /// “Invite Friends” label on white pill (warning tone — on-brand emphasis).
  static const Color referralCtaLabel = warning;

  // ── Interaction ────────────────────────────────────────────────────────────

  static const Color hoverSurface = Color(0xFFF0EFE9);
  static const Color hoverSelected = Color(0xFFD6E8F7);
  static const Color panelShadow = Color(0x0A000000);

  /// Shimmer / skeleton block fill.
  static const Color shimmer = hoverSurface;

  /// Shimmer animation base and highlight (documents, vault previews).
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // ── Chat ───────────────────────────────────────────────────────────────────

  static const Color chatSentBubble = Color(0xFFE8F4FD);
  static const Color chatSentTimestamp = Color(0xFF7B9AB5);
  static const Color chatSurface = Color(0xFFF2F1ED);
  static const Color chatSurfaceBorder = Color(0xFFE8E7E2);
  static const Color composerBackground = Color(0xFFF8F8F6);
  static const Color recordingDangerBackground = Color(0xFFFFF0EF);
  static const Color recordingDangerBorder = Color(0xFFF5C5C2);
  static const Color brandLight = Color(0xFF5C85DE);

  // ── Dividers & de-emphasised text ──────────────────────────────────────────

  static const Color dividerSubtle = Color(0xFFEEEDE8);
  static const Color dividerMuted = Color(0xFFDDDDD8);
  static const Color textPlaceholder = Color(0xFF888888);
  static const Color textDisabled = Color(0xFFBBBBBB);
  static const Color textCaption = Color(0xFFCCCCCC);

  // ── Rating & success heroes ─────────────────────────────────────────────────

  static const Color ratingStar = Color(0xFFFFB800);
  static const Color successHeroDark = Color(0xFF1A4731);
  static const Color successHeroMid = Color(0xFF2D6A4F);
  static const Color successGradientEnd = Color(0xFF27C28D);
  static const Color successGradientLight = Color(0xFFF5FAF0);
  static const Color successSurfaceLight = Color(0xFFF0F9F4);
  static const Color successMutedBackgroundAlt = Color(0xFFE1F5EE);

  // ── Onboarding / auth accents ────────────────────────────────────────────────

  static const Color onboardingAccentNavy = Color(0xFF234A83);
  static const Color onboardingAccentGreen = Color(0xFF0F6A25);
  static const Color warningDark = Color(0xFF8C6B00);
  static const Color referralTileBackground = Color(0xFFFAFAF8);
  static const Color referralTileBorder = Color(0xFFECEAE4);

  // ── Marketing / overlay shadows ────────────────────────────────────────────

  static const Color surfaceWarm = Color(0xFFF7F6F2);
  static const Color shadowSubtle = Color(0x14000000);
  static const Color shadowFaint = Color(0x08000000);
}
