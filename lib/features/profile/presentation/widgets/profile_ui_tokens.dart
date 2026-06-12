import 'package:flutter/material.dart';
import 'package:go_customer/core/layout/app_breakpoints.dart';

/// Bottom padding for profile scroll content above the floating bottom nav.
double profileShellFloatingNavExtra(BuildContext context) {
  if (!AppBreakpoints.useMobileShell(context)) return 0;
  final bottomInset = MediaQuery.paddingOf(context).bottom;
  return bottomInset + 64 + 24;
}

/// Local palette tokens used across profile presentation widgets.
abstract final class ProfileUi {
  static const Color primary = Color(0xFF378ADD);
  static const Color success = Color(0xFF1D9E75);
  static const Color warning = Color(0xFFBA7517);
  static const Color danger = Color(0xFFE24B4A);
  static const Color surface = Color(0xFFF5F4F0);
  static const Color border = Color(0xFFE0DFD8);
  static const Color textTertiary = Color(0xFFAAAAAA);
  static const Color amberBg = Color(0xFFFAEEDA);
  static const Color blueTint = Color(0xFFE6F1FB);
  static const Color blueText = Color(0xFF185FA5);
  static const Color darkBrown = Color(0xFF633806);
}
