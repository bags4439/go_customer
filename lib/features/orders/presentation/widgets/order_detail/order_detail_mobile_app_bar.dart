import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';
import 'package:go_customer/core/widgets/dashboard_mobile_app_bar.dart';
import 'package:go_router/go_router.dart';

import 'package:go_customer/features/orders/presentation/providers/order_providers.dart';
import 'order_detail_agent_app_bar_title.dart';
import 'package:go_customer/core/theme/app_colors.dart';

/// Mobile order-detail app bar with animated order-ref / agent title.
class OrderDetailMobileAppBar extends ConsumerWidget
    implements PreferredSizeWidget {
  const OrderDetailMobileAppBar({
    super.key,
    required this.orderId,
    required this.isChatTabActive,
  });

  final String orderId;
  final bool isChatTabActive;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 0.5);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      ),
      child: isChatTabActive
          ? OrderDetailAgentAppBarTitle(
              key: const ValueKey('agent'),
              orderId: orderId,
            )
          : Text(
              key: const ValueKey('order'),
              ref.watch(orderProvider(orderId)).valueOrNull?.orderRef ?? '--',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
    );

    return AppBar(
      backgroundColor: dashboardMobileAppBarBackground(context),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: DashboardAppBarToolbar(
        leading: Row(
          children: [
            DashboardAppBarIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              iconColor: AppColors.textPrimary,
              onPressed: () => context.go('/home'),
            ),
            const SizedBox(width: 8),
            Expanded(child: title),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: AppColors.borderSolid),
      ),
    );
  }
}
