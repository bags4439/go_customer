import 'package:flutter_test/flutter_test.dart';
import 'package:go_customer/core/constants/app_constants.dart';
import 'package:go_customer/features/orders/core/utils/order_status_label.dart';

void main() {
  group('orderStatusLabel', () {
    test('maps camelCase status', () {
      expect(
        orderStatusLabel(FirestoreEnumValues.orderStatusAgentAssigned),
        'Agent assigned',
      );
    });

    test('maps snake_case alias', () {
      expect(orderStatusLabel('agent_assigned'), 'Agent assigned');
    });

    test('title-cases unknown snake_case', () {
      expect(orderStatusLabel('some_custom_status'), 'Some Custom Status');
    });
  });
}
