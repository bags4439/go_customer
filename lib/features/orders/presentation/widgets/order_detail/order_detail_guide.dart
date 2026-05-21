import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_customer/features/guide/core/constants/guide_keys.dart';
import 'package:go_customer/features/guide/presentation/providers/guide_providers.dart';
import 'package:go_customer/features/orders/presentation/providers/order_providers.dart';

/// Onboarding flow for order detail: payment coach → timeline → chat → documents.
class OrderDetailGuideBootstrap {
  OrderDetailGuideBootstrap._();

  /// Returns `true` when the payment-request coach should show first.
  static Future<bool> shouldShowPaymentCoach(
    WidgetRef ref,
    String orderId,
  ) async {
    final payment = ref.read(activePaymentRequestProvider(orderId)).valueOrNull;
    if (payment == null) return false;
    final seen = await ref.read(
      hasSeenGuideProvider(GuideKeys.orderPaymentRequest).future,
    );
    return !seen;
  }

  /// Returns `1` when the timeline coach should show after payment coach is done.
  static Future<int?> timelineStepIfNeeded(WidgetRef ref) async {
    final seen = await ref.read(
      hasSeenGuideProvider(GuideKeys.orderTimeline).future,
    );
    return seen ? null : 1;
  }
}
