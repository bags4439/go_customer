import 'package:flutter/material.dart';

import '../layout/dashboard_layout.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'dashboard_mobile_app_bar.dart';

/// Standard chrome for full-screen logged-in flows outside the dashboard shell.
///
/// Surface canvas, column-aligned app bar with white back chip, optional
/// [DashboardPortraitFrame] on the body.
class StandaloneMobileScreenScaffold extends StatelessWidget {
  const StandaloneMobileScreenScaffold({
    super.key,
    required this.title,
    required this.body,
    this.onBack,
    this.actions = const [],
    this.titleStyle,
    this.wrapBodyInFrame = true,
    this.resizeToAvoidBottomInset,
  });

  final String title;
  final Widget body;
  final VoidCallback? onBack;
  final List<Widget> actions;
  final TextStyle? titleStyle;
  final bool wrapBodyInFrame;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final content = wrapBodyInFrame
        ? DashboardPortraitFrame(child: body)
        : body;

    return Scaffold(
      backgroundColor: AppColors.surface,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset ?? true,
      appBar: DashboardMobileTitleAppBar(
        title: title,
        onBack: onBack,
        actions: actions,
        titleStyle: titleStyle ?? dashboardMobileFlowTitleStyle(),
      ),
      body: content,
    );
  }
}

/// Order ref label for standalone app bar actions.
Widget standaloneOrderRefTrailing(String orderRef) {
  return Padding(
    padding: const EdgeInsets.only(right: 4),
    child: Center(
      child: Text(
        orderRef,
        style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}
