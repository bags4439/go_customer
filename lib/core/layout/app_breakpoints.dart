import 'package:flutter/material.dart';

/// Single source of truth for all
/// responsive breakpoints and fluid
/// layout dimensions.
///
/// All panel widths are computed as
/// proportions of the available
/// screen width so the layout
/// adapts gracefully at any size.
/// Use LayoutBuilder width, not
/// MediaQuery, wherever possible
/// so widgets reflow on resize.
class AppBreakpoints {
  AppBreakpoints._();

  // ── Breakpoints ──────────────

  /// Below this → mobile bottom nav.
  static const double tablet = 600;

  /// At or above this → web sidebar.
  static const double web = 960;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tablet;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= tablet && w < web;
  }

  static bool isWeb(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= web;

  // ── Fluid sidebar ─────────────

  /// Fraction of screen width the
  /// sidebar occupies on web.
  static const double _sidebarFraction = 0.16;
  static const double _sidebarMin = 200.0;
  static const double _sidebarMax = 260.0;

  /// Call with LayoutBuilder width
  /// for accurate resize behaviour.
  static double sidebarWidth(double availableWidth) =>
      (availableWidth * _sidebarFraction).clamp(_sidebarMin, _sidebarMax);

  // ── Icon rail (tablet) ────────

  static const double iconRailWidth = 56.0;

  // ── Timeline panel (order detail)

  /// Fraction of content width
  /// (screen minus sidebar) that
  /// the timeline middle panel
  /// occupies.
  static const double _timelineFraction = 0.28;
  static const double _timelineMin = 220.0;
  static const double _timelineMax = 320.0;

  static double timelinePanelWidth(double contentWidth) =>
      (contentWidth * _timelineFraction).clamp(_timelineMin, _timelineMax);

  // ── Right detail/summary panels ─

  /// Used for preferences selections
  /// panel, profile actions panel etc.
  static const double _rightFraction = 0.20;
  static const double _rightMin = 180.0;
  static const double _rightMax = 240.0;

  static double rightPanelWidth(double contentWidth) =>
      (contentWidth * _rightFraction).clamp(_rightMin, _rightMax);

  // ── Content max-width ──────────

  /// Maximum width for readable text
  /// content inside any main panel.
  static const double _contentFraction = 0.72;
  static const double _contentMin = 440.0;
  static const double _contentMax = 780.0;

  static double contentMaxWidth(double contentWidth) =>
      (contentWidth * _contentFraction).clamp(_contentMin, _contentMax);

  // ── Typography scale ───────────

  /// Extra font size added on wide
  /// screens (≥ 1280px) so text
  /// reads well on large monitors.
  /// Apply via scaledFontSize().
  static double scaledFontSize(double base, double screenWidth) {
    if (screenWidth >= 1280) {
      return base + 1.0;
    }
    return base;
  }

  // ── Auth split layout ──────────

  static const double _authFormFraction = 0.38;
  static const double _authFormMin = 340.0;
  static const double _authFormMax = 520.0;

  static double authFormWidth(double screenWidth) =>
      (screenWidth * _authFormFraction).clamp(_authFormMin, _authFormMax);
}
