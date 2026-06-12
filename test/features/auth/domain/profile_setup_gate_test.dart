import 'package:flutter_test/flutter_test.dart';
import 'package:go_customer/features/auth/domain/entities/app_user.dart';
import 'package:go_customer/features/auth/domain/profile_setup_gate.dart';

void main() {
  group('isProfileMinimumCompleteMap', () {
    test('returns false when document is missing', () {
      expect(isProfileMinimumCompleteMap(null, exists: false), isFalse);
    });

    test('returns false when fullName is empty', () {
      expect(
        isProfileMinimumCompleteMap({'fullName': '  '}, exists: true),
        isFalse,
      );
    });

    test('returns false when country is missing', () {
      expect(
        isProfileMinimumCompleteMap({'fullName': 'Edem'}, exists: true),
        isFalse,
      );
    });

    test('returns true when fullName and country are set', () {
      expect(
        isProfileMinimumCompleteMap(
          {'fullName': 'Edem Mensah', 'country': 'GH'},
          exists: true,
        ),
        isTrue,
      );
    });
  });

  group('isProfileMinimumCompleteUser', () {
    test('returns false for null user', () {
      expect(isProfileMinimumCompleteUser(null), isFalse);
    });

    test('returns true for complete user', () {
      const user = AppUser(
        id: 'u1',
        fullName: 'Edem Mensah',
        phone: '+233200000000',
        email: null,
        role: 'buyer',
        location: 'Accra',
        country: 'GH',
        isFirstTimeBuyer: true,
        isVerified: false,
      );
      expect(isProfileMinimumCompleteUser(user), isTrue);
    });
  });
}
