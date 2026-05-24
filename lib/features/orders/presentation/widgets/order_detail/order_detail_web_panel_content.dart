import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_customer/features/documents/presentation/screens/document_detail_screen.dart';
import 'package:go_customer/features/clearance/presentation/screens/clearance_screen.dart';
import 'package:go_customer/features/delivery/presentation/screens/delivery_screen.dart';
import 'package:go_customer/features/orders/domain/entities/order_view.dart';
import 'package:go_customer/features/orders/presentation/models/web_order_panel_task.dart';
import 'package:go_customer/features/orders/presentation/providers/order_providers.dart';
import 'package:go_customer/features/orders/presentation/screens/buyer_review_screen.dart';
import 'package:go_customer/features/payments/presentation/screens/payment_confirmed_screen.dart';
import 'package:go_customer/features/payments/presentation/screens/payment_processing_screen.dart';
import 'package:go_customer/features/payments/presentation/screens/payment_request_view_screen.dart';
import 'package:go_customer/features/repairs/presentation/screens/repair_screen.dart';
import 'package:go_customer/features/shipping/presentation/screens/shipping_screen.dart';
import 'order_detail_web_navigation.dart';
import 'order_detail_web_step_detail.dart';

/// Renders the active [WebOrderPanelTask] for the web right column.
class OrderDetailWebPanelContent extends ConsumerWidget {
  const OrderDetailWebPanelContent({
    super.key,
    required this.orderId,
    required this.order,
    required this.task,
  });

  final String orderId;
  final OrderView? order;
  final WebOrderPanelTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onClose = () => OrderDetailWebNavigation.closePanel(ref);
    final onChat = () => OrderDetailWebNavigation.openChat(context, ref, orderId);

    return switch (task) {
      WebOrderPanelDefault() => const SizedBox.shrink(),
      WebOrderPanelTimelineStep(:final stageKey) => OrderDetailWebStepDetail(
        orderId: orderId,
        order: order,
        stageKey: stageKey,
        onBack: onClose,
        onChatTap: onChat,
      ),
      WebOrderPanelShipping(:final orderId) => ShippingScreen(
        orderId: orderId,
        embedInWebPanel: true,
        onClosePanel: onClose,
      ),
      WebOrderPanelClearance(:final orderId) => ClearanceScreen(
        orderId: orderId,
        embedInWebPanel: true,
        onClosePanel: onClose,
        onOpenChat: onChat,
      ),
      WebOrderPanelRepair(:final orderId) => RepairScreen(
        orderId: orderId,
        embedInWebPanel: true,
        onClosePanel: onClose,
        onOpenChat: onChat,
        onOpenDelivery: () =>
            OrderDetailWebNavigation.openDelivery(context, ref, orderId),
      ),
      WebOrderPanelDelivery(:final orderId) => DeliveryScreen(
        orderId: orderId,
        embedInWebPanel: true,
        onClosePanel: onClose,
        onOpenPaymentRequest: (requestId) =>
            OrderDetailWebNavigation.openPaymentRequest(
          context,
          ref,
          orderId: orderId,
          requestId: requestId,
        ),
      ),
      WebOrderPanelPaymentRequest(:final orderId, :final requestId) =>
        PaymentRequestViewScreen(
          orderId: orderId,
          requestId: requestId,
          embedInWebPanel: true,
          onClosePanel: onClose,
        ),
      WebOrderPanelPaymentProcessing(
        :final orderId,
        :final requestId,
        :final paymentId,
      ) =>
        PaymentProcessingScreen(
          orderId: orderId,
          requestId: requestId,
          paymentId: paymentId,
          embedInWebPanel: true,
        ),
      WebOrderPanelPaymentConfirmed(
        :final orderId,
        :final requestId,
        :final paymentId,
      ) =>
        PaymentConfirmedScreen(
          orderId: orderId,
          requestId: requestId,
          paymentId: paymentId,
          embedInWebPanel: true,
          onClosePanel: onClose,
        ),
      WebOrderPanelReview(:final orderId) => BuyerReviewScreen(
        orderId: orderId,
        embedInWebPanel: true,
        onClosePanel: onClose,
      ),
      WebOrderPanelDocument(:final orderId, :final documentId) =>
        DocumentDetailScreen(
          orderId: orderId,
          documentId: documentId,
          embedInWebPanel: true,
          onClosePanel: onClose,
        ),
    };
  }
}

/// Resolves order ref for panel chrome titles.
String? orderRefLabel(WidgetRef ref, String orderId) {
  return ref.watch(orderProvider(orderId)).valueOrNull?.orderRef;
}
