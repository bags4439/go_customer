import '../../../orders/data/models/order_timeline_model.dart';
import '../../../orders/domain/entities/order_view.dart';
import '../../../orders/presentation/utils/active_order_stage.dart';

/// True when the order's current stage is the timeline [searching] step.
bool isOrderOnSearchingStep({
  required OrderView? order,
  required List<OrderTimelineModel>? timeline,
}) {
  return isOrderOnStage(
    order: order,
    timeline: timeline,
    stageKey: 'searching',
  );
}
