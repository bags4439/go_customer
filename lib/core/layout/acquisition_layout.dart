import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_breakpoints.dart';

/// Responsive rules for the pre-home acquisition funnel:
/// onboarding, auth/login, and new-user profile setup.
///
/// Phone and tablet portrait use a single-column "phone" layout.
/// Desktop (≥960dp) and tablet landscape use the web split layout.
class AcquisitionLayout {
  AcquisitionLayout._();

  /// Max readable width for phone layout on portrait tablet.
  static const double phoneColumnMaxWidth = 520;

  /// Web split layout: wide desktop or tablet held in landscape.
  static bool useWebLayout(BuildContext context) =>
      AppBreakpoints.useWebShell(context);

  /// Single-column phone layout: handset or tablet portrait.
  static bool usePhoneLayout(BuildContext context) =>
      AppBreakpoints.useMobileShell(context);

  /// Tablet in portrait (600–959dp wide) — needs centred column framing.
  static bool isPortraitTablet(BuildContext context) {
    return AppBreakpoints.useMobileShell(context) &&
        !AppBreakpoints.isMobile(context);
  }

  static double phoneContentMaxWidth(BuildContext context) {
    if (isPortraitTablet(context)) return phoneColumnMaxWidth;
    return double.infinity;
  }

  static EdgeInsets phoneContentPadding(BuildContext context) {
    if (isPortraitTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 40);
    }
    return const EdgeInsets.symmetric(horizontal: 24);
  }
}

/// Centres acquisition content and applies portrait-tablet max width.
///
/// On true mobile, [child] is returned unchanged so existing full-bleed
/// layouts (e.g. onboarding hero) keep their behaviour.
class AcquisitionPhoneColumn extends StatelessWidget {
  const AcquisitionPhoneColumn({
    super.key,
    required this.child,
    this.verticallyCenter = false,
    this.frameBackground = true,
  });

  final Widget child;
  final bool verticallyCenter;
  final bool frameBackground;

  @override
  Widget build(BuildContext context) {
    if (!AcquisitionLayout.isPortraitTablet(context)) {
      return child;
    }

    final maxWidth = AcquisitionLayout.phoneContentMaxWidth(context);
    final padding = AcquisitionLayout.phoneContentPadding(context);

    Widget column = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (verticallyCenter) {
      column = LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(child: column),
            ),
          );
        },
      );
    }

    if (!frameBackground) {
      return Align(alignment: Alignment.topCenter, child: column);
    }

    return ColoredBox(
      color: AppColors.surface,
      child: verticallyCenter
          ? column
          : Align(alignment: Alignment.topCenter, child: column),
    );
  }
}
