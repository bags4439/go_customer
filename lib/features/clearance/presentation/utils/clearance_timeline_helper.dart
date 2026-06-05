import '../../data/models/duty_clearance_model.dart';
import '../../../orders/core/constants/order_timeline_constants.dart';
import '../../../orders/data/models/order_timeline_model.dart';
import '../../../orders/domain/entities/order_view.dart';

/// True when the order's current stage is the timeline [clearance] step.
bool isOrderOnClearanceStep({
  required OrderView? order,
  required List<OrderTimelineModel>? timeline,
}) {
  if (order == null || timeline == null || timeline.isEmpty) return false;

  final clearanceStages =
      timeline.where((stage) => stage.stageKey == 'clearance').toList();
  if (clearanceStages.isEmpty) return false;

  return order.stageNumber == clearanceStages.first.stageNumber;
}

/// Agent has published clearance progress beyond the initial placeholder.
bool hasAgentClearanceUpdate(DutyClearanceModel? clearance) {
  if (clearance == null) return false;
  if (clearance.notes != null && clearance.notes!.trim().isNotEmpty) {
    return true;
  }
  return clearance.graStatus != GraStatus.notStarted;
}

/// Amber caption above the timeline clearance card when there is new agent info.
String? clearanceTimelineUpdateCaption(DutyClearanceModel clearance) {
  if (!hasAgentClearanceUpdate(clearance)) return null;

  switch (clearance.graStatus) {
    case GraStatus.submitted:
      return OrderTimelineConstants.clearanceUpdateSubmitted;
    case GraStatus.assessed:
      return OrderTimelineConstants.clearanceUpdateAssessed;
    case GraStatus.paid:
      return OrderTimelineConstants.clearanceUpdatePaid;
    case GraStatus.cleared:
      return OrderTimelineConstants.clearanceUpdateCleared;
    case GraStatus.notStarted:
      return OrderTimelineConstants.clearanceUpdateNote;
  }
}

/// Home card status line when on clearance step with agent updates.
String? clearanceHomeStatusLine(DutyClearanceModel? clearance) {
  if (!hasAgentClearanceUpdate(clearance)) return null;
  return OrderTimelineConstants.clearanceHomeUpdateLine;
}
