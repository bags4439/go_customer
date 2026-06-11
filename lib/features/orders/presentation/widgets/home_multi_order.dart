import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/layout/app_breakpoints.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';

import '../../../guide/core/constants/guide_keys.dart';
import '../../../guide/presentation/widgets/guide_contextual_hint_banner.dart';
import '../../../referral/presentation/widgets/referral_promo_card.dart';
import '../../../vehicle_options/presentation/providers/vehicle_option_providers.dart';
import '../../domain/entities/order_view.dart';
import 'home_layout_utils.dart';
import 'home_metric_card.dart';
import 'home_order_card.dart';
import 'home_staggered_item.dart';
import 'home_theme.dart';

class HomeMultiOrderBody extends ConsumerWidget {
  final List<OrderView> orders;
  final int pendingPayments;
  final int pendingReviews;
  final int pendingVehicleListings;
  final String? currentUserName;

  const HomeMultiOrderBody({
    super.key,
    required this.orders,
    required this.pendingPayments,
    required this.pendingReviews,
    required this.pendingVehicleListings,
    required this.currentUserName,
  });

  String _subtitleText(int active, int needsAction) {
    if (needsAction > 0) {
      return '$active active ${active == 1 ? 'order' : 'orders'} · '
          '$needsAction ${needsAction == 1 ? 'needs' : 'need'} '
          'your attention';
    }
    return '$active active ${active == 1 ? 'order' : 'orders'}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWeb = AppBreakpoints.isWeb(context);

    final active = orders
        .where((o) => !o.isCompleted && !o.isCancelled)
        .length;
    final completed = orders.where((o) => o.isCompleted).length;
    final needsAction =
        orders.where((o) => o.needsPayment).length +
        pendingPayments +
        pendingReviews +
        pendingVehicleListings;

    final sorted = [...orders]
      ..sort((a, b) {
        final aListings = ref.watch(pendingVehicleFeedbackCountProvider(a.id));
        final bListings = ref.watch(pendingVehicleFeedbackCountProvider(b.id));
        if (a.needsPayment && !b.needsPayment) return -1;
        if (!a.needsPayment && b.needsPayment) return 1;
        if (aListings > 0 && bListings == 0) return -1;
        if (aListings == 0 && bListings > 0) return 1;
        if (!a.isCompleted && b.isCompleted) return -1;
        if (a.isCompleted && !b.isCompleted) return 1;
        if (a.isCancelled && !b.isCancelled) return 1;
        if (!a.isCancelled && b.isCancelled) return -1;
        return b.stageNumber.compareTo(a.stageNumber);
      });

    final listChildren = <Widget>[
      const GuideHint(guideKey: GuideKeys.homeOrders),
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi ${currentUserName?.split(' ').first ?? ''} 👋',
              style: AppTextStyles.displaySmall.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: HomeColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _subtitleText(active, needsAction),
              style: AppTextStyles.bodySmall.copyWith(
                color: HomeColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(
            child: HomeMetricCard(
              label: 'Active',
              value: '$active',
              valueColor: HomeColors.primary,
              icon: Icons.directions_car_outlined,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: HomeMetricCard(
              label: 'Action needed',
              value: '$needsAction',
              valueColor: needsAction > 0
                  ? HomeColors.danger
                  : HomeColors.textTertiary,
              icon: Icons.notifications_outlined,
              pulse: needsAction > 0,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: HomeMetricCard(
              label: 'Completed',
              value: '$completed',
              valueColor: HomeColors.success,
              icon: Icons.check_circle_outline,
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      Text(
        'YOUR ORDERS',
        style: AppTextStyles.sectionLabel.copyWith(
          fontWeight: FontWeight.w600,
          color: HomeColors.textTertiary,
        ),
      ),
      const SizedBox(height: 10),
      ...sorted.asMap().entries.map(
        (entry) => HomeStaggeredItem(
          index: entry.key,
          child: HomeOrderCard(order: entry.value),
        ),
      ),
      const SizedBox(height: 8),
      const SizedBox(height: 4),
      GestureDetector(
        onTap: () => GoRouter.of(context).push('/preferences/new'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HomeColors.bgPrimary,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: HomeColors.primary.withValues(alpha: 0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: HomeColors.primary.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: HomeColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.add_circle_outline,
                  color: HomeColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buy another car',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: HomeColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Start a new import order',
                      style: AppTextStyles.cardLabel,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: HomeColors.primary,
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      isWeb ? SizedBox.shrink() : const ReferralPromoCard(),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            24 + homeShellFloatingNavScrollBottomExtra(context),
          ),
          children: listChildren,
        ),
      ),
    );
  }
}
