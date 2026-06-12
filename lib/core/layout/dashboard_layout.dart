import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'acquisition_layout.dart';
import 'app_breakpoints.dart';

/// Layout rules for the logged-in dashboard on the mobile shell (phone +
/// portrait tablet).
///
/// Phone: surface canvas with a constant [mobileHorizontalInset] from the
/// screen edge (frame + chrome). Portrait tablet: centred 520dp column with
/// the same inset inside the column.
class DashboardLayout {
  DashboardLayout._();

  /// Standard horizontal inset for mobile-shell dashboard screens.
  static const double mobileHorizontalInset = 16;

  /// Max width for body content on portrait tablet only.
  static const double contentMaxWidth = 520;

  /// @deprecated Use [mobileHorizontalInset].
  static const double phoneGutterWidth = mobileHorizontalInset;

  /// @deprecated Use [mobileHorizontalInset] inside the portrait-tablet column.
  static const double toolbarInnerPadding = mobileHorizontalInset;

  static bool usesMobileContentFrame(BuildContext context) =>
      AppBreakpoints.useMobileShell(context);

  static bool isPortraitTablet(BuildContext context) =>
      AcquisitionLayout.isPortraitTablet(context);

  static double contentColumnMaxWidth(BuildContext context) {
    if (isPortraitTablet(context)) return contentMaxWidth;
    return double.infinity;
  }

  /// Surface gutter on phone — the single horizontal inset from screen edge.
  static EdgeInsets phoneGutterPadding(BuildContext context) {
    if (!usesMobileContentFrame(context) || isPortraitTablet(context)) {
      return EdgeInsets.zero;
    }
    return const EdgeInsets.symmetric(horizontal: mobileHorizontalInset);
  }

  /// Horizontal padding for scrollable body content inside [DashboardPortraitFrame].
  ///
  /// Phone: 0 — the frame already insets by [mobileHorizontalInset].
  /// Portrait tablet: [mobileHorizontalInset] inside the 520dp column.
  static double bodyContentHorizontalPadding(BuildContext context) {
    if (!usesMobileContentFrame(context)) return 0;
    if (isPortraitTablet(context)) return mobileHorizontalInset;
    return 0;
  }

  /// Convenience wrapper for common scroll-view padding.
  static EdgeInsets bodyScrollPadding(
    BuildContext context, {
    double top = 0,
    double bottom = 0,
  }) {
    final horizontal = bodyContentHorizontalPadding(context);
    return EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom);
  }
}

/// Surface canvas + content column insets for the mobile shell body.
///
/// Scroll areas use [AppColors.surface]; individual cards stay white.
/// No-op on web shell. Never wrap app bars or bottom navigation.
class DashboardPortraitFrame extends StatelessWidget {
  const DashboardPortraitFrame({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!DashboardLayout.usesMobileContentFrame(context)) {
      return child;
    }

    return ColoredBox(
      color: AppColors.surface,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: DashboardLayout.phoneGutterPadding(context),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: DashboardLayout.contentColumnMaxWidth(context),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
