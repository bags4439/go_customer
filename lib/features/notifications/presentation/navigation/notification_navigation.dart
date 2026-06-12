import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../orders/presentation/widgets/order_detail/order_detail_web_navigation.dart';
import '../../../profile/presentation/navigation/profile_id_verification_navigation.dart';
import '../../domain/entities/notification_entity.dart';

/// Routes the user to the screen implied by a notification tap/action.
abstract final class NotificationNavigation {
  NotificationNavigation._();

  static void open(
    BuildContext context,
    WidgetRef ref,
    NotificationEntity notification,
  ) {
    final orderId = notification.orderId;
    switch (notification.type) {
      case 'payment_request':
        final requestId = _extractRequestId(notification.actionUrl);
        if (orderId != null && requestId != null) {
          OrderDetailWebNavigation.navigateToPaymentRequest(
            context,
            orderId: orderId,
            requestId: requestId,
          );
        }
      case 'payment_confirmed':
        if (orderId != null) context.push('/order/$orderId');
      case 'bid_won':
      case 'bid_lost':
        if (orderId != null) context.push('/order/$orderId/bid-status');
      case 'stage_update':
      case 'agent_assigned':
      case 'order_edited':
      case 'order_cancelled':
        if (orderId != null) context.push('/order/$orderId');
      case 'message':
        if (orderId != null) context.push('/order/$orderId?tab=chat');
      case 'shipping_update':
        if (orderId != null) context.push('/order/$orderId/shipping');
      case 'arrival':
        if (orderId != null) context.push('/order/$orderId/clearance');
      case 'vehicle_listing':
        if (orderId != null) {
          OrderDetailWebNavigation.openVehicleOptions(
            context,
            ref,
            orderId: orderId,
          );
        }
      case 'id_reminder':
        ProfileIdVerificationNavigation.open(context);
      case 'system':
        if (orderId != null) context.push('/order/$orderId');
      default:
        if (orderId != null) context.push('/order/$orderId');
    }
  }

  static String? _extractRequestId(String? actionUrl) {
    if (actionUrl == null) return null;
    final parts = actionUrl.split('/payment-request/');
    if (parts.length < 2) return null;
    return parts.last.split('/').first.split('?').first;
  }
}
