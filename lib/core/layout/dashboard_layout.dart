import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'acquisition_layout.dart';

/// Layout rules for the logged-in dashboard on portrait tablet.
///
/// Portrait tablet = mobile UI (same as phone) with a centred 520dp content
/// column and off-white gutters. App bar and bottom nav stay full width.
class DashboardLayout {
  DashboardLayout._();

  /// Max width for scrollable body content on portrait tablet.
  static const double contentMaxWidth = 520;

  static bool isPortraitTablet(BuildContext context) =>
      AcquisitionLayout.isPortraitTablet(context);
}

/// Centres body content on portrait tablet with surface gutters.
///
/// No-op on phone and web shell. Never wrap app bars or bottom navigation.
class DashboardPortraitFrame extends StatelessWidget {
  const DashboardPortraitFrame({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!DashboardLayout.isPortraitTablet(context)) {
      return child;
    }

    return ColoredBox(
      color: AppColors.surface,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: DashboardLayout.contentMaxWidth,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
