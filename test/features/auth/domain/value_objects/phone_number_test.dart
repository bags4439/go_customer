import 'package:flutter_test/flutter_test.dart';
import 'package:go_customer/features/auth/domain/value_objects/phone_number.dart';

void main() {
  group('PhoneNumber.fromDialCodeAndDigits', () {
    test('normalizes a Ghanaian local number with a leading zero', () {
      final result = PhoneNumber.fromDialCodeAndDigits(
        dialCode: '+233',
        digits: '0271154324',
      );

      expect(result.fold((_) => null, (phone) => phone.value), '+233271154324');
    });

    test('keeps a Ghanaian local number without a leading zero', () {
      final result = PhoneNumber.fromDialCodeAndDigits(
        dialCode: '+233',
        digits: '271154324',
      );

      expect(result.fold((_) => null, (phone) => phone.value), '+233271154324');
    });

    test('does not strip a leading zero for other dial codes', () {
      final result = PhoneNumber.fromDialCodeAndDigits(
        dialCode: '+39',
        digits: '0612345678',
      );

      expect(result.fold((_) => null, (phone) => phone.value), '+390612345678');
    });
  });
}
