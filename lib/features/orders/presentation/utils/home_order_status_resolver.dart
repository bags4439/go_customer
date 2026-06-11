import '../../../../core/constants/app_constants.dart';
import '../../../clearance/data/models/duty_clearance_model.dart';
import '../../../clearance/presentation/utils/clearance_timeline_helper.dart';
import '../../../payments/data/models/payment_request_model.dart';
import '../../../repairs/data/models/repair_job_model.dart';
import '../../core/constants/order_timeline_constants.dart';
import '../../data/models/order_timeline_model.dart';
import '../../domain/entities/order_view.dart';
import 'active_order_stage.dart';
import 'repair_timeline_resolver.dart';

/// Home dashboard subtitle — only the active timeline step may contribute
/// contextual copy (plus terminal states and global payment action).
String resolveHomeOrderSubtitle({
  required OrderView order,
  required List<OrderTimelineModel>? timeline,
  RepairJobModel? repairJob,
  List<PaymentRequestModel>? pendingPayments,
  DutyClearanceModel? clearance,
  int pendingVehicleListings = 0,
}) {
  // Tier 0 — terminal
  if (order.isCancelled) return 'This order was cancelled';
  if (order.isCompleted) return 'Delivered · order complete';

  // Tier 1 — global action (CTA shown separately; subtitle reinforces)
  if (order.needsPayment) return 'Payment required to continue';

  // Tier 2 — active stage
  if (timeline != null && timeline.isNotEmpty) {
    final active = resolveActiveStage(
      order: order,
      timeline: timeline,
      repairJob: repairJob,
    );
    if (active != null) {
      final pending = pendingPayments ?? const <PaymentRequestModel>[];
      final line = _subtitleForActiveStage(
        order: order,
        activeStage: active,
        repairJob: repairJob,
        clearance: clearance,
        pendingPayments: pending,
        pendingVehicleListings: pendingVehicleListings,
        totalStages: visibleTimelineStages(timeline, order, repairJob).length,
      );
      if (line != null && line.isNotEmpty) return line;
    }
  }

  // Tier 3 — legacy fallback
  return _legacyOrderStatusFallback(order);
}

String? _subtitleForActiveStage({
  required OrderView order,
  required OrderTimelineModel activeStage,
  RepairJobModel? repairJob,
  DutyClearanceModel? clearance,
  required List<PaymentRequestModel> pendingPayments,
  required int pendingVehicleListings,
  required int totalStages,
}) {
  switch (activeStage.stageKey) {
    case 'searching':
      if (pendingVehicleListings > 0) {
        return pendingVehicleListings == 1
            ? '1 option awaiting your feedback'
            : '$pendingVehicleListings options awaiting your feedback';
      }
      return _legacyOrderStatusFallback(order);

    case 'clearance':
      final clearanceLine = clearanceHomeStatusLine(clearance);
      if (clearanceLine != null) return clearanceLine;
      if (activeStage.detail?.isNotEmpty == true) {
        return activeStage.detail!;
      }
      return _legacyOrderStatusFallback(order);

    case 'repair':
      return RepairTimelineResolver.summaryDetail(
        repairJob,
        pendingPayment: RepairTimelineResolver.pendingRepairPayment(
          pendingPayments,
        ),
      );

    case 'delivery':
      if (order.status == AppConstants.statusDeliveryConfirmed) {
        return '🎉 Vehicle received · please rate your experience';
      }
      if (activeStage.detail?.isNotEmpty == true) {
        return activeStage.detail!;
      }
      if (order.status == FirestoreEnumValues.orderStatusDeliveryInProgress) {
        return 'Delivery in progress · tap to view';
      }
      return OrderTimelineConstants.deliveryHomeCtaLine;

    default:
      if (activeStage.detail?.isNotEmpty == true) {
        return activeStage.detail!;
      }
      return 'Step ${order.stageNumber} of $totalStages';
  }
}

/// Whether the home card should show the clearance update CTA banner.
bool shouldShowClearanceHomeCta({
  required OrderView order,
  required List<OrderTimelineModel>? timeline,
  DutyClearanceModel? clearance,
  RepairJobModel? repairJob,
}) {
  if (order.isCompleted || order.isCancelled) return false;
  if (!isOrderOnStage(
    order: order,
    timeline: timeline,
    stageKey: 'clearance',
    repairJob: repairJob,
  )) {
    return false;
  }
  return hasAgentClearanceUpdate(clearance);
}

String _legacyOrderStatusFallback(OrderView order) {
  switch (order.status) {
    case FirestoreEnumValues.orderStatusOpen:
      return 'Submitted · matching you with an agent';
    case FirestoreEnumValues.orderStatusAgentAssigned:
      if (order.isNewVehicle) {
        return 'Agent contacting suppliers in China';
      }
      return switch (order.purchaseOrigin) {
        'us_canada' => 'Agent searching US auctions',
        'dubai' => 'Agent sourcing from Dubai',
        'china' => 'Agent contacting China dealers',
        _ => 'Your agent is on it',
      };
    case FirestoreEnumValues.orderStatusSearching:
      return switch (order.purchaseOrigin) {
        'us_canada' => 'Searching US & Canada auctions',
        'dubai' => 'Sourcing options from Dubai',
        'china' => 'Searching China dealers',
        _ => 'Searching for your vehicle',
      };
    case FirestoreEnumValues.orderStatusBidPlaced:
      return 'A bid is live on your chosen vehicle';
    case FirestoreEnumValues.orderStatusBidWon:
      return 'Vehicle secured · next steps in chat';
    case FirestoreEnumValues.orderStatusBidLost:
      return 'Could not secure vehicle · agent will suggest options';
    case FirestoreEnumValues.orderStatusPaymentReceived:
      return 'Payment received · moving to shipping';
    case FirestoreEnumValues.orderStatusShipping:
      return '🚢 Your car is in transit';
    case FirestoreEnumValues.orderStatusArrived:
      return 'Vehicle arrived · customs & clearance next';
    case FirestoreEnumValues.orderStatusDutyPending:
      return 'Import duty assessment in progress';
    case FirestoreEnumValues.orderStatusDutyPaid:
      return 'Duty paid · clearance in progress';
    case FirestoreEnumValues.orderStatusClearanceInProgress:
      return 'Port clearance in progress';
    case FirestoreEnumValues.orderStatusClearanceComplete:
      return 'Clearance complete';
    case FirestoreEnumValues.orderStatusRepairPending:
      return 'Repairs pending your confirmation';
    case FirestoreEnumValues.orderStatusRepairInProgress:
      return 'Repairs in progress';
    case FirestoreEnumValues.orderStatusRepairComplete:
      return 'Repairs complete · delivery next';
    case FirestoreEnumValues.orderStatusDeliveryInProgress:
      return 'Delivery in progress · tap to view';
    case AppConstants.statusDeliveryConfirmed:
      return '🎉 Vehicle received · please rate your experience';
    case AppConstants.statusDelivered:
      return 'Order complete · thank you for choosing AutoImport GH';
    case FirestoreEnumValues.orderStatusDormant:
    default:
      return 'No recent activity · open chat if needed';
  }
}
