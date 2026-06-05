import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../orders/presentation/providers/order_providers.dart';
import '../../../orders/presentation/providers/order_timeline_providers.dart';
import '../utils/clearance_timeline_helper.dart';

/// Whether the order's active timeline step is [clearance].
final isOrderOnClearanceStepProvider = Provider.family<bool, String>((
  ref,
  orderId,
) {
  final order = ref.watch(orderProvider(orderId)).valueOrNull;
  final timeline = ref.watch(orderTimelineProvider(orderId)).valueOrNull;
  return isOrderOnClearanceStep(order: order, timeline: timeline);
});

/// True when the buyer is on the clearance step and the agent has posted an update.
final clearanceHasAgentUpdateProvider = Provider.family<bool, String>((
  ref,
  orderId,
) {
  if (!ref.watch(isOrderOnClearanceStepProvider(orderId))) return false;
  final clearance = ref.watch(orderClearanceProvider(orderId)).valueOrNull;
  return hasAgentClearanceUpdate(clearance);
});
