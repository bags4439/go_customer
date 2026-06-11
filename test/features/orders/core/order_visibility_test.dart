import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_customer/features/orders/core/order_visibility.dart';

void main() {
  group('isOrderVisibleFromMap', () {
    test('returns true when hiddenAt is null', () {
      expect(isOrderVisibleFromMap({}), isTrue);
      expect(isOrderVisibleFromMap({'hiddenAt': null}), isTrue);
    });

    test('returns false when hiddenAt is set', () {
      expect(
        isOrderVisibleFromMap({
          'hiddenAt': Timestamp.fromDate(DateTime(2025)),
        }),
        isFalse,
      );
    });
  });

  group('hiddenAtFromMap', () {
    test('parses timestamp', () {
      final date = DateTime(2025, 3, 1);
      expect(
        hiddenAtFromMap({'hiddenAt': Timestamp.fromDate(date)}),
        date,
      );
    });

    test('returns null when missing', () {
      expect(hiddenAtFromMap({}), isNull);
    });
  });
}
