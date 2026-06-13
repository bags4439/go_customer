import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'order_detail/order_detail_web_navigation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/providers/preferred_currency_provider.dart';
import '../../domain/entities/order_view.dart';
import '../../domain/entities/payment_request_view.dart';
import 'home_theme.dart';
import 'package:go_customer/core/theme/app_colors.dart';

class HomeOrderStatusBadge extends StatelessWidget {
  final OrderView order;

  const HomeOrderStatusBadge({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    late String label;
    late Color bg;
    late Color text;

    if (order.needsPayment) {
      label = 'Pay now';
      bg = AppColors.dangerMutedBackground;
      text = AppColors.danger;
    } else if (order.isCompleted) {
      label = 'Delivered';
      bg = AppColors.successMutedBackground;
      text = AppColors.success;
    } else {
      switch (order.status) {
        case FirestoreEnumValues.orderStatusOpen:
          label = 'Submitted';
          bg = AppColors.surface;
          text = AppColors.textSecondary;
          break;
        case FirestoreEnumValues.orderStatusAgentAssigned:
          label = 'Agent assigned';
          bg = AppColors.infoBackground;
          text = AppColors.accent;
          break;
        case FirestoreEnumValues.orderStatusSearching:
          label = 'Searching';
          bg = AppColors.amberBackground;
          text = AppColors.warning;
          break;
        case FirestoreEnumValues.orderStatusBidPlaced:
          label = 'Bid placed';
          bg = AppColors.amberBackground;
          text = AppColors.warning;
          break;
        case FirestoreEnumValues.orderStatusBidWon:
          label = 'Vehicle found';
          bg = AppColors.successMutedBackground;
          text = AppColors.success;
          break;
        case FirestoreEnumValues.orderStatusBidLost:
          label = 'Bid lost';
          bg = AppColors.dangerMutedBackground;
          text = AppColors.danger;
          break;
        case FirestoreEnumValues.orderStatusPaymentReceived:
          label = 'Paid';
          bg = AppColors.successMutedBackground;
          text = AppColors.success;
          break;
        case FirestoreEnumValues.orderStatusShipping:
          label = 'Shipping';
          bg = AppColors.infoBackground;
          text = AppColors.accent;
          break;
        case FirestoreEnumValues.orderStatusArrived:
          label = 'Arrived';
          bg = AppColors.successMutedBackground;
          text = AppColors.success;
          break;
        case FirestoreEnumValues.orderStatusDutyPending:
          label = 'Duty pending';
          bg = AppColors.amberBackground;
          text = AppColors.warning;
          break;
        case FirestoreEnumValues.orderStatusDutyPaid:
          label = 'Duty paid';
          bg = AppColors.infoBackground;
          text = AppColors.accent;
          break;
        case FirestoreEnumValues.orderStatusClearanceInProgress:
          label = 'Clearance';
          bg = AppColors.infoBackground;
          text = AppColors.accent;
          break;
        case FirestoreEnumValues.orderStatusClearanceComplete:
          label = 'Cleared';
          bg = AppColors.successMutedBackground;
          text = AppColors.success;
          break;
        case FirestoreEnumValues.orderStatusRepairPending:
          label = 'Repairs';
          bg = AppColors.amberBackground;
          text = AppColors.warning;
          break;
        case FirestoreEnumValues.orderStatusRepairInProgress:
          label = 'In repair';
          bg = AppColors.amberBackground;
          text = AppColors.warning;
          break;
        case FirestoreEnumValues.orderStatusRepairComplete:
          label = 'Repairs done';
          bg = AppColors.successMutedBackground;
          text = AppColors.success;
          break;
        case FirestoreEnumValues.orderStatusCancelled:
          label = 'Cancelled';
          bg = AppColors.dangerMutedBackground;
          text = AppColors.danger;
          break;
        case FirestoreEnumValues.orderStatusDeliveryInProgress:
          label = 'Delivery';
          bg = AppColors.infoBackground;
          text = AppColors.accent;
          break;
        case AppConstants.statusDeliveryConfirmed:
          label = 'Rate us ⭐';
          bg = AppColors.successMutedBackground;
          text = AppColors.success;
          break;
        case AppConstants.statusDelivered:
          label = 'Complete';
          bg = AppColors.successMutedBackground;
          text = AppColors.success;
          break;
        case FirestoreEnumValues.orderStatusDormant:
          label = 'On hold';
          bg = AppColors.surface;
          text = AppColors.textSecondary;
          break;
        default:
          label = 'In progress';
          bg = AppColors.surface;
          text = AppColors.textSecondary;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: homeTextStyle(size: 10, weight: FontWeight.w500, color: text),
      ),
    );
  }
}

class HomeOrderPaymentInlineCta extends ConsumerWidget {
  final PaymentRequestView payment;
  final String orderId;

  const HomeOrderPaymentInlineCta({
    super.key,
    required this.payment,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(preferredCurrencyProvider);
    final display = CurrencyFormatter.formatForDisplay(
      usdAmount: payment.amountUsd,
      preferredCurrency: currency,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.brand,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  display.primary,
                  style: homeTextStyle(
                    size: 14,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (display.hasSecondary) ...[
                  const SizedBox(height: 1),
                  Text(
                    display.secondary!,
                    style: homeTextStyle(
                      size: 10,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  FirestoreEnumValues.paymentRequestTypeLabels[payment.type] ??
                      payment.type,
                  style: homeTextStyle(
                    size: 11,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => OrderDetailWebNavigation.navigateToPaymentRequest(
              context,
              orderId: orderId,
              requestId: payment.id,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Pay now',
                style: homeTextStyle(
                  size: 12,
                  weight: FontWeight.w600,
                  color: AppColors.brand,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
