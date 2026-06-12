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

  group('isRegistrationCompleteMap', () {
    test('returns false when document is missing', () {
      expect(isRegistrationCompleteMap(null, exists: false), isFalse);
    });

    test('returns false when registrationComplete is false', () {
      expect(
        isRegistrationCompleteMap(
          {
            'fullName': 'Edem Mensah',
            'country': 'GH',
            'registrationComplete': false,
          },
          exists: true,
        ),
        isFalse,
      );
    });

    test('returns true when registrationComplete is true', () {
      expect(
        isRegistrationCompleteMap(
          {
            'fullName': 'Edem Mensah',
            'country': 'GH',
            'registrationComplete': true,
          },
          exists: true,
        ),
        isTrue,
      );
    });

    test('grandfathers legacy users without registrationComplete flag', () {
      expect(
        isRegistrationCompleteMap(
          {'fullName': 'Edem Mensah', 'country': 'GH'},
          exists: true,
        ),
        isTrue,
      );
    });
  });

  group('registrationResumeStepKey', () {
    test('returns null when registration is complete', () {
      expect(
        registrationResumeStepKey(
          {
            'fullName': 'Edem',
            'country': 'GH',
            'registrationComplete': true,
          },
          exists: true,
        ),
        isNull,
      );
    });

    test('returns name when identity is incomplete', () {
      expect(
        registrationResumeStepKey({'fullName': 'Edem'}, exists: true),
        'name',
      );
    });

    test('returns referral after name step', () {
      expect(
        registrationResumeStepKey(
          {
            'fullName': 'Edem Mensah',
            'country': 'GH',
            'registrationComplete': false,
            'registrationWizardStep': RegistrationWizardStepKeys.referral,
          },
          exists: true,
        ),
        RegistrationWizardStepKeys.referral,
      );
    });

    test('returns contactChannels when wizard step is contact', () {
      expect(
        registrationResumeStepKey(
          {
            'fullName': 'Edem Mensah',
            'country': 'GH',
            'registrationComplete': false,
            'registrationWizardStep':
                RegistrationWizardStepKeys.contactChannels,
          },
          exists: true,
        ),
        RegistrationWizardStepKeys.contactChannels,
      );
    });
  });

  group('isRegistrationCompleteUser', () {
    test('returns false for null user', () {
      expect(isRegistrationCompleteUser(null), isFalse);
    });

    test('returns false when registrationComplete is false', () {
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
        registrationComplete: false,
      );
      expect(isRegistrationCompleteUser(user), isFalse);
    });

    test('returns true when registrationComplete is true', () {
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
        registrationComplete: true,
      );
      expect(isRegistrationCompleteUser(user), isTrue);
    });

    test('grandfathers legacy user without registrationComplete flag', () {
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
      expect(isRegistrationCompleteUser(user), isTrue);
    });
  });
}
