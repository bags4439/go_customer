import '../../../../core/constants/app_constants.dart';

/// Human-readable label for an order [status] Firestore value.
String orderStatusLabel(String status) {
  if (status.isEmpty) return '—';

  const labels = {
    FirestoreEnumValues.orderStatusOpen: 'Open',
    FirestoreEnumValues.orderStatusAgentAssigned: 'Agent assigned',
    FirestoreEnumValues.orderStatusSearching: 'Searching',
    FirestoreEnumValues.orderStatusBidPlaced: 'Bid placed',
    FirestoreEnumValues.orderStatusBidWon: 'Bid won',
    FirestoreEnumValues.orderStatusBidLost: 'Bid lost',
    FirestoreEnumValues.orderStatusPaymentPending: 'Payment pending',
    FirestoreEnumValues.orderStatusPaymentReceived: 'Payment received',
    FirestoreEnumValues.orderStatusShipping: 'Shipping',
    FirestoreEnumValues.orderStatusArrived: 'Arrived',
    FirestoreEnumValues.orderStatusDutyPending: 'Duty pending',
    FirestoreEnumValues.orderStatusDutyPaid: 'Duty paid',
    FirestoreEnumValues.orderStatusClearanceInProgress: 'Clearance in progress',
    FirestoreEnumValues.orderStatusClearanceComplete: 'Clearance complete',
    FirestoreEnumValues.orderStatusRepairPending: 'Repair pending',
    FirestoreEnumValues.orderStatusRepairInProgress: 'Repair in progress',
    FirestoreEnumValues.orderStatusRepairComplete: 'Repair complete',
    FirestoreEnumValues.orderStatusDeliveryInProgress: 'Delivery in progress',
    FirestoreEnumValues.orderStatusDeliveryConfirmed: 'Delivery confirmed',
    FirestoreEnumValues.orderStatusDelivered: 'Delivered',
    FirestoreEnumValues.orderStatusCancelled: 'Cancelled',
    FirestoreEnumValues.orderStatusDormant: 'Dormant',
    // Legacy / stage-key aliases occasionally stored on status
    'agent_assigned': 'Agent assigned',
    'preferences_submitted': 'Preferences submitted',
    'deposit_paid': 'Deposit paid',
    'vehicle_balance': 'Vehicle balance',
  };

  if (labels.containsKey(status)) return labels[status]!;

  // snake_case → Title Case fallback
  if (status.contains('_')) {
    return status
        .split('_')
        .map(
          (w) => w.isEmpty
              ? w
              : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  // camelCase → spaced words
  final spaced = status.replaceAllMapped(
    RegExp(r'([a-z])([A-Z])'),
    (m) => '${m[1]} ${m[2]}',
  );
  if (spaced != status) {
    return spaced[0].toUpperCase() + spaced.substring(1).toLowerCase();
  }

  return status;
}
