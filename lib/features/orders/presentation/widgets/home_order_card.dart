import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:go_customer/core/constants/app_constants.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

import '../../../clearance/presentation/providers/clearance_timeline_providers.dart';
import '../../../clearance/presentation/utils/clearance_timeline_helper.dart';
import '../../../vehicle_options/core/constants/vehicle_option_constants.dart';
import '../../../vehicle_options/presentation/providers/vehicle_option_providers.dart';
import '../../core/constants/order_timeline_constants.dart';
import 'order_detail/order_detail_web_navigation.dart';
import '../providers/order_providers.dart';
import '../providers/order_timeline_providers.dart';
import 'home_order_status.dart';
import 'home_theme.dart';

class HomeOrderReviewCta extends ConsumerWidget {
  const HomeOrderReviewCta({
    super.key,
    required this.orderId,
  });

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => OrderDetailWebNavigation.navigateToReview(
          context,
          orderId: orderId,
        ),
        borderRadius: BorderRadius.circular(8),
        child: Container(
        decoration: BoxDecoration(
          color: HomeColors.successBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: HomeColors.success.withValues(alpha: 0.25),
            width: 0.5,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    OrderTimelineConstants.deliveryHomeCtaTitle,
                    style: homeTextStyle(
                      size: 14,
                      weight: FontWeight.w600,
                      color: HomeColors.success,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    OrderTimelineConstants.deliveryHomeCtaLine,
                    style: homeTextStyle(
                      size: 11,
                      color: HomeColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: HomeColors.bgPrimary,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: HomeColors.success.withValues(alpha: 0.35),
                  width: 0.5,
                ),
              ),
              child: Text(
                OrderTimelineConstants.deliveryHomeCtaAction,
                style: homeTextStyle(
                  size: 12,
                  weight: FontWeight.w600,
                  color: HomeColors.success,
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class HomeOrderClearanceUpdateCta extends ConsumerWidget {
  const HomeOrderClearanceUpdateCta({
    super.key,
    required this.orderId,
  });

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: HomeColors.infoBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: HomeColors.primary.withValues(alpha: 0.25),
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  OrderTimelineConstants.clearanceHomeCtaTitle,
                  style: homeTextStyle(
                    size: 14,
                    weight: FontWeight.w600,
                    color: HomeColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  OrderTimelineConstants.clearanceHomeUpdateLine,
                  style: homeTextStyle(
                    size: 11,
                    color: HomeColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => OrderDetailWebNavigation.openClearance(
              context,
              ref,
              orderId,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: HomeColors.bgPrimary,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: HomeColors.primary.withValues(alpha: 0.35),
                  width: 0.5,
                ),
              ),
              child: Text(
                OrderTimelineConstants.clearanceHomeCtaAction,
                style: homeTextStyle(
                  size: 12,
                  weight: FontWeight.w600,
                  color: HomeColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeOrderVehicleFeedbackCta extends ConsumerWidget {
  const HomeOrderVehicleFeedbackCta({
    super.key,
    required this.orderId,
    required this.pendingCount,
  });

  final String orderId;
  final int pendingCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: HomeColors.warningBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: HomeColors.warning.withValues(alpha: 0.25),
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  VehicleOptionConstants.homeCtaTitle(pendingCount),
                  style: homeTextStyle(
                    size: 14,
                    weight: FontWeight.w600,
                    color: HomeColors.amberText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  VehicleOptionConstants.pendingBannerBody,
                  style: homeTextStyle(
                    size: 11,
                    color: HomeColors.amberText,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => OrderDetailWebNavigation.openVehicleOptions(
              context,
              ref,
              orderId: orderId,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: HomeColors.bgPrimary,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: HomeColors.warning, width: 0.5),
              ),
              child: Text(
                VehicleOptionConstants.homeCtaAction,
                style: homeTextStyle(
                  size: 12,
                  weight: FontWeight.w600,
                  color: HomeColors.warning,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeOrderOriginPill extends StatelessWidget {
  final String origin;

  const HomeOrderOriginPill({super.key, required this.origin});

  @override
  Widget build(BuildContext context) {
    final (String label, Color bg, Color text) = switch (origin) {
      'us_canada' => (
        '🇺🇸 US / Canada',
        HomeColors.pillSoftBlue,
        HomeColors.infoText,
      ),
      'dubai' => ('🇦🇪 Dubai', HomeColors.warningBg, HomeColors.amberText),
      'china' => (
        '🇨🇳 China',
        HomeColors.successBg,
        HomeColors.successMutedForeground,
      ),
      _ => (origin, HomeColors.bgSecondary, HomeColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(fontSize: 10, color: text),
      ),
    );
  }
}

class HomeOrderCard extends ConsumerWidget {
  final OrderView order;

  const HomeOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter.of(context);
    final paymentAsync = ref.watch(activePaymentRequestProvider(order.id));
    final repairAsync = ref.watch(orderRepairJobProvider(order.id));
    final pendingAsync = ref.watch(pendingPaymentRequestsProvider(order.id));
    final pendingListings =
        ref.watch(pendingVehicleFeedbackCountProvider(order.id));
    final clearanceAsync = ref.watch(orderClearanceProvider(order.id));
    final clearanceUpdate = ref.watch(clearanceHasAgentUpdateProvider(order.id));
    final clearance = clearanceAsync.valueOrNull;

    final statusDescription = homeOrderStatusDescription(
      order,
      repairJob: repairAsync.valueOrNull,
      pendingPayments: pendingAsync.valueOrNull,
      pendingVehicleListings: pendingListings,
      clearanceStatusLine: clearanceHomeStatusLine(clearance),
    );

    final needsReview =
        order.status == AppConstants.statusDeliveryConfirmed;

    final accentColor = order.needsPayment
        ? HomeColors.danger
        : pendingListings > 0
        ? HomeColors.warning
        : needsReview
        ? HomeColors.success
        : clearanceUpdate
        ? HomeColors.primary
        : order.isCompleted
        ? HomeColors.success
        : HomeColors.primary;

    final progress = (order.stageNumber.clamp(1, 9)) / 9.0;
    const radius = 14.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: HomeColors.bgPrimary,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: () => router.push('/order/${order.id}'),
          borderRadius: BorderRadius.circular(radius),
          splashColor: HomeColors.infoBg,
          highlightColor: HomeColors.bgSecondary,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: HomeColors.border, width: 0.5),
              borderRadius: BorderRadius.circular(radius),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 5,
                      color: accentColor,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        accentColor.withValues(alpha: 0.15),
                                        accentColor.withValues(alpha: 0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: accentColor.withValues(alpha: 0.2),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.directions_car_filled,
                                    size: 22,
                                    color: accentColor,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${order.make ?? 'Vehicle'} ${order.model ?? ''}'
                                            .trim(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.labelLarge,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        order.orderRef,
                                        style: homeTextStyle(
                                          size: 11,
                                          color: HomeColors.textTertiary,
                                        ),
                                      ),
                                      if (order.purchaseOrigin != 'any') ...[
                                        const SizedBox(height: 4),
                                        HomeOrderOriginPill(
                                          origin: order.purchaseOrigin,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                HomeOrderStatusBadge(order: order),
                              ],
                            ),
                            const SizedBox(height: 10),
                            paymentAsync.when(
                              data: (p) {
                                if (p != null) {
                                  return HomeOrderPaymentInlineCta(
                                    payment: p,
                                    orderId: order.id,
                                  );
                                }
                                if (pendingListings > 0) {
                                  return HomeOrderVehicleFeedbackCta(
                                    orderId: order.id,
                                    pendingCount: pendingListings,
                                  );
                                }
                                if (needsReview) {
                                  return HomeOrderReviewCta(orderId: order.id);
                                }
                                if (clearanceUpdate) {
                                  return HomeOrderClearanceUpdateCta(
                                    orderId: order.id,
                                  );
                                }
                                return Text(
                                  statusDescription,
                                  style: homeTextStyle(
                                    size: 12,
                                    color: HomeColors.textSecondary,
                                  ),
                                );
                              },
                              loading: () => const SizedBox(height: 14),
                              error: (_, __) => Text(
                                statusDescription,
                                style: homeTextStyle(
                                  size: 12,
                                  color: HomeColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 6,
                                      backgroundColor: HomeColors.border,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        accentColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Step ${order.stageNumber} of 9',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: HomeColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
