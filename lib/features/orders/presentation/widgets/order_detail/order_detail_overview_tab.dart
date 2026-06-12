import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/layout/app_breakpoints.dart';
import 'package:go_customer/core/layout/dashboard_layout.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';
import 'package:go_customer/core/constants/app_constants.dart';
import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/features/guide/core/constants/guide_keys.dart';
import 'package:go_customer/features/guide/presentation/widgets/guide_contextual_hint_banner.dart';
import 'package:go_customer/features/orders/core/constants/order_timeline_constants.dart';
import 'package:go_customer/features/orders/presentation/providers/order_providers.dart';
import 'order_detail_web_navigation.dart';
import 'package:go_customer/features/orders/presentation/widgets/order_timeline_widget.dart';
import 'package:go_customer/features/payments/data/models/payment_request_model.dart';
import 'order_detail_car_card.dart';
import 'order_detail_cancel_section.dart';
import 'order_detail_remove_cancelled_section.dart';
import 'order_not_available_view.dart';
import 'order_detail_payment_card.dart';

/// Overview tab: payment CTA, vehicle card (mobile), timeline, edit/cancel.
class OrderDetailOverviewTab extends ConsumerWidget {
  const OrderDetailOverviewTab({
    super.key,
    required this.orderId,
    this.onChatTap,
  });

  final String orderId;
  final VoidCallback? onChatTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderProvider(orderId));
    final paymentAsync = ref.watch(activePaymentRequestProvider(orderId));
    return orderAsync.when(
      data: (order) {
        if (order == null) {
          return const OrderNotAvailableView();
        }
        return ListView(
          padding: DashboardLayout.bodyScrollPadding(
            context,
            top: 20,
            bottom: 32,
          ),
          children: [
            const GuideHint(guideKey: GuideKeys.orderTimeline),
            paymentAsync.when(
              data: (p) {
                if (p == null) return const SizedBox.shrink();
                final typeLabel =
                    FirestoreEnumValues.paymentRequestTypeLabels[p.type
                            is PaymentRequestType
                        ? (p.type as PaymentRequestType).firestoreValue
                        : p.type.toString()] ??
                    p.type.toString();
                final deadlineStr = p.deadlineAt != null
                    ? formatOrderDetailDeadline(p.deadlineAt!)
                    : null;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const GuideHint(guideKey: GuideKeys.orderPaymentRequest),
                    OrderDetailPaymentCard(
                      payment: p,
                      typeLabel: typeLabel,
                      deadlineText: deadlineStr,
                      onPayPressed: () =>
                          OrderDetailWebNavigation.openPaymentRequest(
                        context,
                        ref,
                        orderId: order.id,
                        requestId: p.id,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            if (!AppBreakpoints.useWebShell(context))
              OrderDetailCarCard(order: order),
            const SizedBox(height: 14),
            Text(
              OrderTimelineConstants.journeyTitle,
              style: AppTextStyles.titleMedium.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 14),
            OrderTimelineWidget(
              orderId: orderId,
              order: order,
              onChatTap: onChatTap,
              onStepTapped: AppBreakpoints.useWebShell(context)
                  ? (stageKey) =>
                      OrderDetailWebNavigation.openTimelineStep(ref, stageKey)
                  : null,
            ),
            if (ref.watch(canCancelOrderProvider(order.id))) ...[
              const SizedBox(height: 20),
              OrderDetailCancelSection(orderId: order.id),
            ],
            if (ref.watch(canRemoveCancelledOrderProvider(order.id))) ...[
              const SizedBox(height: 20),
              OrderDetailRemoveCancelledSection(orderId: order.id),
            ],
            const SizedBox(height: 32),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.secondary),
      ),
      error: (_, __) => Center(
        child: Text(
          'Unable to load order',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
