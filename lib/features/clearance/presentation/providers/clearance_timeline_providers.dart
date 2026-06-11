import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../orders/presentation/providers/order_providers.dart';
import '../../../orders/presentation/providers/order_timeline_providers.dart';
import '../../../orders/presentation/utils/active_order_stage.dart';
import '../../../orders/presentation/utils/home_order_status_resolver.dart';

/// Whether the order's active timeline step is [clearance].
final isOrderOnClearanceStepProvider = Provider.family<bool, String>((
  ref,
  orderId,
) {
  final order = ref.watch(orderProvider(orderId)).valueOrNull;
  final timeline = ref.watch(orderTimelineProvider(orderId)).valueOrNull;
  final repairJob = ref.watch(orderRepairJobProvider(orderId)).valueOrNull;
  return isOrderOnStage(
    order: order,
    timeline: timeline,
    stageKey: 'clearance',
    repairJob: repairJob,
  );
});

/// True when the buyer is on the clearance step and the agent has posted an update.
final clearanceHasAgentUpdateProvider = Provider.family<bool, String>((
  ref,
  orderId,
) {
  final order = ref.watch(orderProvider(orderId)).valueOrNull;
  if (order == null) return false;
  final timeline = ref.watch(orderTimelineProvider(orderId)).valueOrNull;
  final clearance = ref.watch(orderClearanceProvider(orderId)).valueOrNull;
  final repairJob = ref.watch(orderRepairJobProvider(orderId)).valueOrNull;
  return shouldShowClearanceHomeCta(
    order: order,
    timeline: timeline,
    clearance: clearance,
    repairJob: repairJob,
  );
});
