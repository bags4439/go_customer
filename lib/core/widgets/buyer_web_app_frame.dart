import 'package:flutter/material.dart';

import '../layout/app_breakpoints.dart';
import '../layout/panel_divider.dart';
import '../theme/app_colors.dart';

/// Builds the sidebar for a given inner frame width (the width inside the clip).
typedef BuyerWebFrameSidebarBuilder = Widget Function(double frameWidth);

/// Centred 1280px web chrome: sidebar column + divider + main content.
///
/// Used by [WebAppShell] and [BuyerDashboardShell] so the frame is defined once.
class BuyerWebAppFrame extends StatelessWidget {
  const BuyerWebAppFrame({
    super.key,
    required this.sidebarBuilder,
    required this.content,
  });

  final BuyerWebFrameSidebarBuilder sidebarBuilder;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final frameWidth = constraints.maxWidth;
                  final sw = AppBreakpoints.sidebarWidth(frameWidth);
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(width: sw, child: sidebarBuilder(frameWidth)),
                      const PanelDivider(),
                      Expanded(child: content),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
