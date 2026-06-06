import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/route_constants.dart';
import '../../../../../core/layout/app_breakpoints.dart';
import '../../models/web_order_panel_task.dart';
import '../../providers/order_detail_providers.dart';

/// Opens order sub-flows in the web right panel or via GoRouter on mobile.
abstract final class OrderDetailWebNavigation {
  OrderDetailWebNavigation._();

  static bool _isWeb(BuildContext context) =>
      AppBreakpoints.isWeb(context);

  static void openTimelineStep(WidgetRef ref, String stageKey) {
    ref.read(webOrderPanelTaskProvider.notifier).state =
        WebOrderPanelTimelineStep(stageKey);
  }

  static void openShipping(BuildContext context, WidgetRef ref, String orderId) {
    if (_isWeb(context)) {
      ref.read(webOrderPanelTaskProvider.notifier).state =
          WebOrderPanelShipping(orderId: orderId);
      return;
    }
    context.push('/order/$orderId/shipping');
  }

  static void openClearance(BuildContext context, WidgetRef ref, String orderId) {
    if (_isWeb(context)) {
      ref.read(webOrderPanelTaskProvider.notifier).state =
          WebOrderPanelClearance(orderId: orderId);
      return;
    }
    context.push('/order/$orderId/clearance');
  }

  static void openRepair(BuildContext context, WidgetRef ref, String orderId) {
    if (_isWeb(context)) {
      ref.read(webOrderPanelTaskProvider.notifier).state =
          WebOrderPanelRepair(orderId: orderId);
      return;
    }
    context.push('/order/$orderId/repair');
  }

  static void openDelivery(BuildContext context, WidgetRef ref, String orderId) {
    if (_isWeb(context)) {
      ref.read(webOrderPanelTaskProvider.notifier).state =
          WebOrderPanelDelivery(orderId: orderId);
      return;
    }
    context.push('/order/$orderId/delivery');
  }

  static void openReview(BuildContext context, WidgetRef ref, String orderId) {
    if (_isWeb(context)) {
      final onOrderDetail = GoRouterState.of(
        context,
      ).matchedLocation.startsWith('/order/$orderId');
      if (!onOrderDetail) {
        navigateToReview(context, orderId: orderId);
        return;
      }
      ref.read(webOrderPanelTaskProvider.notifier).state =
          WebOrderPanelReview(orderId: orderId);
      return;
    }
    context.push('/order/$orderId/review');
  }

  /// Entry from home, notifications, etc. Web → order detail + review panel.
  static void navigateToReview(
    BuildContext context, {
    required String orderId,
  }) {
    if (_isWeb(context)) {
      context.go(
        '/order/$orderId'
        '?${RouteConstants.reviewPanelQuery}=1',
      );
      return;
    }
    context.push('/order/$orderId/review');
  }

  /// Opens checkout in-panel when already on web order detail; otherwise navigates.
  static void openPaymentRequest(
    BuildContext context,
    WidgetRef ref, {
    required String orderId,
    required String requestId,
  }) {
    if (_isWeb(context)) {
      ref.read(webOrderPanelTaskProvider.notifier).state =
          WebOrderPanelPaymentRequest(
        orderId: orderId,
        requestId: requestId,
      );
      return;
    }
    context.push('/order/$orderId/payment-request/$requestId');
  }

  /// Entry from home, notifications, chat, etc. Web → order detail + panel.
  static void navigateToPaymentRequest(
    BuildContext context, {
    required String orderId,
    required String requestId,
  }) {
    if (_isWeb(context)) {
      context.go(
        '/order/$orderId'
        '?${RouteConstants.paymentRequestQuery}=$requestId',
      );
      return;
    }
    context.push('/order/$orderId/payment-request/$requestId');
  }

  static void openPaymentProcessing(
    WidgetRef ref, {
    required String orderId,
    required String requestId,
    required String paymentId,
  }) {
    ref.read(webOrderPanelTaskProvider.notifier).state =
        WebOrderPanelPaymentProcessing(
      orderId: orderId,
      requestId: requestId,
      paymentId: paymentId,
    );
  }

  static void openPaymentConfirmed(
    WidgetRef ref, {
    required String orderId,
    required String requestId,
    required String paymentId,
  }) {
    ref.read(webOrderPanelTaskProvider.notifier).state =
        WebOrderPanelPaymentConfirmed(
      orderId: orderId,
      requestId: requestId,
      paymentId: paymentId,
    );
  }

  /// Switches to chat tab; on web clears panel task first.
  static void openChat(BuildContext context, WidgetRef ref, String orderId) {
    if (_isWeb(context)) {
      resetWebOrderPanelTask(ref);
    }
    context.go('/order/$orderId?tab=chat');
  }

  static void openIdDocument(
    BuildContext context,
    WidgetRef ref, {
    required String orderId,
  }) {
    if (_isWeb(context)) {
      ref.read(webOrderPanelTaskProvider.notifier).state =
          WebOrderPanelIdDocument(orderId: orderId);
      return;
    }
    context.pushNamed(RouteConstants.idVerification);
  }

  static void openDocument(
    BuildContext context,
    WidgetRef ref, {
    required String orderId,
    required String documentId,
  }) {
    if (_isWeb(context)) {
      ref.read(webOrderPanelTaskProvider.notifier).state =
          WebOrderPanelDocument(
        orderId: orderId,
        documentId: documentId,
      );
      return;
    }
    context.push('/order/$orderId/documents/$documentId');
  }

  static void openVehicleOptions(
    BuildContext context,
    WidgetRef ref, {
    required String orderId,
  }) {
    if (_isWeb(context)) {
      final onOrderDetail = GoRouterState.of(
        context,
      ).matchedLocation.startsWith('/order/$orderId');
      if (!onOrderDetail) {
        context.go('/order/$orderId');
      }
      ref.read(webOrderPanelTaskProvider.notifier).state =
          WebOrderPanelVehicleOptions(orderId: orderId);
      return;
    }
    context.push('/order/$orderId/vehicle-options');
  }

  static void openVehicleOptionDetail(
    BuildContext context,
    WidgetRef ref, {
    required String orderId,
    required String vehicleOptionId,
  }) {
    if (_isWeb(context)) {
      ref.read(webOrderPanelTaskProvider.notifier).state =
          WebOrderPanelVehicleOptionDetail(
        orderId: orderId,
        vehicleOptionId: vehicleOptionId,
      );
      return;
    }
    context.push('/order/$orderId/vehicle/$vehicleOptionId');
  }

  static void closePanel(WidgetRef ref) {
    resetWebOrderPanelTask(ref);
  }
}
