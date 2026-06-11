import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'order_detail/order_detail_web_navigation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/providers/preferred_currency_provider.dart';
import '../../domain/entities/order_view.dart';
import '../../domain/entities/payment_request_view.dart';
import 'home_theme.dart';

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
      bg = HomeColors.dangerBg;
      text = HomeColors.danger;
    } else if (order.isCompleted) {
      label = 'Delivered';
      bg = HomeColors.successBg;
      text = HomeColors.success;
    } else {
      switch (order.status) {
        case FirestoreEnumValues.orderStatusOpen:
          label = 'Submitted';
          bg = HomeColors.bgSecondary;
          text = HomeColors.textSecondary;
          break;
        case FirestoreEnumValues.orderStatusAgentAssigned:
          label = 'Agent assigned';
          bg = HomeColors.infoBg;
          text = HomeColors.infoText;
          break;
        case FirestoreEnumValues.orderStatusSearching:
          label = 'Searching';
          bg = HomeColors.warningBg;
          text = HomeColors.warning;
          break;
        case FirestoreEnumValues.orderStatusBidPlaced:
          label = 'Bid placed';
          bg = HomeColors.warningBg;
          text = HomeColors.warning;
          break;
        case FirestoreEnumValues.orderStatusBidWon:
          label = 'Vehicle found';
          bg = HomeColors.successBg;
          text = HomeColors.success;
          break;
        case FirestoreEnumValues.orderStatusBidLost:
          label = 'Bid lost';
          bg = HomeColors.dangerBg;
          text = HomeColors.danger;
          break;
        case FirestoreEnumValues.orderStatusPaymentReceived:
          label = 'Paid';
          bg = HomeColors.successBg;
          text = HomeColors.success;
          break;
        case FirestoreEnumValues.orderStatusShipping:
          label = 'Shipping';
          bg = HomeColors.infoBg;
          text = HomeColors.infoText;
          break;
        case FirestoreEnumValues.orderStatusArrived:
          label = 'Arrived';
          bg = HomeColors.successBg;
          text = HomeColors.success;
          break;
        case FirestoreEnumValues.orderStatusDutyPending:
          label = 'Duty pending';
          bg = HomeColors.warningBg;
          text = HomeColors.warning;
          break;
        case FirestoreEnumValues.orderStatusDutyPaid:
          label = 'Duty paid';
          bg = HomeColors.infoBg;
          text = HomeColors.infoText;
          break;
        case FirestoreEnumValues.orderStatusClearanceInProgress:
          label = 'Clearance';
          bg = HomeColors.infoBg;
          text = HomeColors.infoText;
          break;
        case FirestoreEnumValues.orderStatusClearanceComplete:
          label = 'Cleared';
          bg = HomeColors.successBg;
          text = HomeColors.success;
          break;
        case FirestoreEnumValues.orderStatusRepairPending:
          label = 'Repairs';
          bg = HomeColors.warningBg;
          text = HomeColors.warning;
          break;
        case FirestoreEnumValues.orderStatusRepairInProgress:
          label = 'In repair';
          bg = HomeColors.warningBg;
          text = HomeColors.warning;
          break;
        case FirestoreEnumValues.orderStatusRepairComplete:
          label = 'Repairs done';
          bg = HomeColors.successBg;
          text = HomeColors.success;
          break;
        case FirestoreEnumValues.orderStatusCancelled:
          label = 'Cancelled';
          bg = HomeColors.dangerBg;
          text = HomeColors.danger;
          break;
        case FirestoreEnumValues.orderStatusDeliveryInProgress:
          label = 'Delivery';
          bg = HomeColors.infoBg;
          text = HomeColors.infoText;
          break;
        case AppConstants.statusDeliveryConfirmed:
          label = 'Rate us ⭐';
          bg = HomeColors.successBg;
          text = HomeColors.success;
          break;
        case AppConstants.statusDelivered:
          label = 'Complete';
          bg = HomeColors.successBg;
          text = HomeColors.success;
          break;
        case FirestoreEnumValues.orderStatusDormant:
          label = 'On hold';
          bg = HomeColors.bgSecondary;
          text = HomeColors.textSecondary;
          break;
        default:
          label = 'In progress';
          bg = HomeColors.bgSecondary;
          text = HomeColors.textSecondary;
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
        color: HomeColors.primary,
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
                color: HomeColors.bgPrimary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Pay now',
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
