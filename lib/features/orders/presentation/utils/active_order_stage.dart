import '../../data/models/order_timeline_model.dart';
import '../../domain/entities/order_view.dart';
import '../../../repairs/data/models/repair_job_model.dart';

/// Timeline stages shown to the buyer.
///
/// Repair is hidden when [OrderView.repairOptedIn] is false and no repair job
/// has `optedIn: true`. When opted in, repair shows on the journey (including
/// as a future step before the buyer reaches it).
List<OrderTimelineModel> visibleTimelineStages(
  List<OrderTimelineModel> timeline,
  OrderView order,
  RepairJobModel? repairJob,
) {
  final repairOptedIn = order.repairOptedIn ||
      (repairJob?.optedIn ?? false);
  if (repairOptedIn) return timeline;
  return timeline.where((s) => s.stageKey != 'repair').toList();
}

/// The stage that matches [order.stageNumber] on the visible journey.
OrderTimelineModel? resolveActiveStage({
  required OrderView order,
  required List<OrderTimelineModel> timeline,
  RepairJobModel? repairJob,
}) {
  final visible = visibleTimelineStages(timeline, order, repairJob);
  if (visible.isEmpty) return null;
  return visible.firstWhere(
    (s) => s.stageNumber == order.stageNumber,
    orElse: () => visible.last,
  );
}

/// True when the buyer's current stage is [stageKey] on the visible timeline.
bool isOrderOnStage({
  required OrderView? order,
  required List<OrderTimelineModel>? timeline,
  required String stageKey,
  RepairJobModel? repairJob,
}) {
  if (order == null || timeline == null || timeline.isEmpty) return false;

  final visible = visibleTimelineStages(timeline, order, repairJob);
  final stages = visible.where((s) => s.stageKey == stageKey).toList();
  if (stages.isEmpty) return false;

  return order.stageNumber == stages.first.stageNumber;
}
