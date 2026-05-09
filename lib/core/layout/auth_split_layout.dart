import 'package:flutter/material.dart';

import 'app_breakpoints.dart';
import 'dark_split_panel.dart';

/// Wraps an auth or onboarding
/// form with an optional dark
/// branded panel on web/tablet.
///
/// On mobile: renders [form] only.
/// On tablet/web: [form] left
/// ([AppBreakpoints.authFormWidth])
/// + [panel] right (flex).
class AuthSplitLayout extends StatelessWidget {
  const AuthSplitLayout({super.key, required this.form, required this.panel});

  /// The form content — shown on
  /// all breakpoints.
  final Widget form;

  /// The dark branded panel —
  /// shown only on tablet and web.
  final DarkSplitPanel panel;

  @override
  Widget build(BuildContext context) {
    if (AppBreakpoints.isMobile(context)) {
      return form;
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final formWidth = AppBreakpoints.authFormWidth(screenWidth);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: formWidth,
          child: ClipRect(child: form),
        ),
        const VerticalDivider(width: .5, thickness: .5),
        Expanded(child: ClipRect(child: panel)),
      ],
    );
  }
}
