import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/layout/dashboard_layout.dart';
import '../../../../core/widgets/dashboard_mobile_app_bar.dart';
import '../../../../core/layout/web_app_body.dart';
import '../../../../core/layout/web_app_shell.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive_layout.dart';

/// Shared chrome for order sub-flows (cancel, cancelled, etc.) on mobile and web.
class OrderFlowScaffold extends ConsumerWidget {
  const OrderFlowScaffold({
    super.key,
    required this.title,
    required this.onBack,
    required this.child,
  });

  final String title;
  final VoidCallback onBack;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWeb = AppBreakpoints.useWebShell(context);
    final body = ColoredBox(
      color: AppColors.surface,
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveLayout.contentMaxWidth(context),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isWeb
                    ? ResponsiveLayout.contentPadding(context).left
                    : DashboardLayout.bodyContentHorizontalPadding(context),
                isWeb ? 32 : 16,
                isWeb
                    ? ResponsiveLayout.contentPadding(context).right
                    : DashboardLayout.bodyContentHorizontalPadding(context),
                32,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );

    if (isWeb) {
      return WebAppShell(
        child: WebAppBody(
          pageTitle: title,
          onBack: onBack,
          body: body,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: DashboardMobileTitleAppBar(
        title: title,
        onBack: onBack,
        titleStyle: dashboardMobileFlowTitleStyle(),
      ),
      body: DashboardPortraitFrame(child: body),
    );
  }
}

/// Centred empty / denied state inside [OrderFlowScaffold].
class OrderFlowMessageBody extends StatelessWidget {
  const OrderFlowMessageBody({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 48),
        Icon(icon, size: 48, color: AppColors.textTertiary),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.titleSmall,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        if (action != null) ...[const SizedBox(height: 24), action!],
        const SizedBox(height: 48),
      ],
    );
  }
}
