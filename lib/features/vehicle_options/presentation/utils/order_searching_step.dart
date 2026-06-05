import '../../../orders/data/models/order_timeline_model.dart';
import '../../../orders/domain/entities/order_view.dart';

/// True when the order's current stage is the timeline [searching] step.
bool isOrderOnSearchingStep({
  required OrderView? order,
  required List<OrderTimelineModel>? timeline,
}) {
  if (order == null || timeline == null || timeline.isEmpty) return false;

  final searchingStages =
      timeline.where((stage) => stage.stageKey == 'searching').toList();
  if (searchingStages.isEmpty) return false;

  return order.stageNumber == searchingStages.first.stageNumber;
}
