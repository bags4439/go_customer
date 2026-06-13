import 'package:flutter/material.dart';

import '../../../../core/layout/app_breakpoints.dart';

/// Bottom padding for profile scroll content above the floating bottom nav.
double profileShellFloatingNavExtra(BuildContext context) {
  if (!AppBreakpoints.useMobileShell(context)) return 0;
  final bottomInset = MediaQuery.paddingOf(context).bottom;
  return bottomInset + 64 + 24;
}
