import 'package:flutter_test/flutter_test.dart';
import 'package:go_customer/core/constants/app_constants.dart';
import 'package:go_customer/features/clearance/data/models/duty_clearance_model.dart';
import 'package:go_customer/features/orders/data/models/order_timeline_model.dart';
import 'package:go_customer/features/orders/domain/entities/order_view.dart';
import 'package:go_customer/features/orders/presentation/utils/home_order_status_resolver.dart';

OrderView _order({
  String status = FirestoreEnumValues.orderStatusRepairPending,
  int stageNumber = 8,
  bool repairOptedIn = true,
}) {
  return OrderView(
    id: 'o1',
    orderRef: 'ORD-1',
    agentId: 'a1',
    status: status,
    stageNumber: stageNumber,
    hasPendingPayment: false,
    firstPaymentMade: true,
    createdAt: null,
    updatedAt: null,
    make: 'Kia',
    model: 'Sorento',
    repairOptedIn: repairOptedIn,
  );
}

List<OrderTimelineModel> _timeline() => [
  const OrderTimelineModel(
    id: '1',
    orderId: 'o1',
    stageNumber: 7,
    stageKey: 'clearance',
    label: 'Clearance',
  ),
  const OrderTimelineModel(
    id: '2',
    orderId: 'o1',
    stageNumber: 8,
    stageKey: 'repair',
    label: 'Repair',
  ),
  const OrderTimelineModel(
    id: '3',
    orderId: 'o1',
    stageNumber: 9,
    stageKey: 'delivery',
    label: 'Delivery',
  ),
];

void main() {
  group('resolveHomeOrderSubtitle', () {
    test('delivered order ignores stale clearance data', () {
      final line = resolveHomeOrderSubtitle(
        order: _order(
          status: AppConstants.statusDelivered,
          stageNumber: 9,
        ),
        timeline: _timeline(),
        clearance: const DutyClearanceModel(
          id: 'c1',
          orderId: 'o1',
          handledBy: 'agent',
          graStatus: GraStatus.cleared,
        ),
      );

      expect(line, 'Delivered · order complete');
    });

    test('repair step shows repair copy not clearance', () {
      final line = resolveHomeOrderSubtitle(
        order: _order(stageNumber: 8),
        timeline: _timeline(),
        clearance: const DutyClearanceModel(
          id: 'c1',
          orderId: 'o1',
          handledBy: 'agent',
          graStatus: GraStatus.cleared,
        ),
      );

      expect(line, contains('repair'));
      expect(line.toLowerCase(), isNot(contains('clearance update')));
    });

    test('clearance step shows clearance update when agent progressed', () {
      final line = resolveHomeOrderSubtitle(
        order: _order(
          status: FirestoreEnumValues.orderStatusClearanceInProgress,
          stageNumber: 7,
        ),
        timeline: _timeline(),
        clearance: const DutyClearanceModel(
          id: 'c1',
          orderId: 'o1',
          handledBy: 'agent',
          graStatus: GraStatus.assessed,
        ),
      );

      expect(line, contains('Clearance update'));
    });
  });

  group('shouldShowClearanceHomeCta', () {
    test('false when delivered even with clearance updates', () {
      expect(
        shouldShowClearanceHomeCta(
          order: _order(
            status: AppConstants.statusDelivered,
            stageNumber: 9,
          ),
          timeline: _timeline(),
          clearance: const DutyClearanceModel(
            id: 'c1',
            orderId: 'o1',
            handledBy: 'agent',
            graStatus: GraStatus.cleared,
          ),
        ),
        isFalse,
      );
    });

    test('true only on active clearance step', () {
      expect(
        shouldShowClearanceHomeCta(
          order: _order(
            status: FirestoreEnumValues.orderStatusClearanceInProgress,
            stageNumber: 7,
          ),
          timeline: _timeline(),
          clearance: const DutyClearanceModel(
            id: 'c1',
            orderId: 'o1',
            handledBy: 'agent',
            graStatus: GraStatus.submitted,
          ),
        ),
        isTrue,
      );

      expect(
        shouldShowClearanceHomeCta(
          order: _order(stageNumber: 8),
          timeline: _timeline(),
          clearance: const DutyClearanceModel(
            id: 'c1',
            orderId: 'o1',
            handledBy: 'agent',
            graStatus: GraStatus.cleared,
          ),
        ),
        isFalse,
      );
    });
  });
}
