import 'package:flutter_test/flutter_test.dart';
import 'package:go_customer/features/orders/data/models/order_timeline_model.dart';
import 'package:go_customer/features/orders/domain/entities/order_view.dart';
import 'package:go_customer/features/orders/presentation/utils/active_order_stage.dart';
import 'package:go_customer/features/preferences/domain/repair_preference_defaults.dart';

OrderView _order({bool repairOptedIn = false}) {
  return OrderView(
    id: 'o1',
    orderRef: 'ORD-1',
    agentId: 'a1',
    status: 'clearanceInProgress',
    stageNumber: 7,
    hasPendingPayment: false,
    firstPaymentMade: true,
    createdAt: null,
    updatedAt: null,
    make: 'Ford',
    model: 'Bronco',
    repairOptedIn: repairOptedIn,
  );
}

List<OrderTimelineModel> _timelineWithRepair() => const [
  OrderTimelineModel(
    id: '1',
    orderId: 'o1',
    stageNumber: 7,
    stageKey: 'clearance',
    label: 'Duty & clearance',
  ),
  OrderTimelineModel(
    id: '2',
    orderId: 'o1',
    stageNumber: 8,
    stageKey: 'repair',
    label: 'Repairs',
  ),
  OrderTimelineModel(
    id: '3',
    orderId: 'o1',
    stageNumber: 9,
    stageKey: 'delivery',
    label: 'Delivery',
  ),
];

void main() {
  group('defaultRepairOptedIn', () {
    test('true for used / auction imports', () {
      expect(defaultRepairOptedIn(isNewVehicle: false), isTrue);
    });

    test('false for brand-new vehicle from China', () {
      expect(defaultRepairOptedIn(isNewVehicle: true), isFalse);
    });
  });

  group('visibleTimelineStages', () {
    test('hides repair when repairOptedIn is false and no repair job', () {
      final visible = visibleTimelineStages(
        _timelineWithRepair(),
        _order(repairOptedIn: false),
        null,
      );

      expect(visible.map((s) => s.stageKey).toList(), [
        'clearance',
        'delivery',
      ]);
    });

    test('shows repair as future step when repairOptedIn is true', () {
      final visible = visibleTimelineStages(
        _timelineWithRepair(),
        _order(repairOptedIn: true),
        null,
      );

      expect(visible.map((s) => s.stageKey).toList(), [
        'clearance',
        'repair',
        'delivery',
      ]);
    });
  });
}
