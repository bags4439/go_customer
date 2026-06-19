import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:go_customer/features/profile/data/delete_user_account_failure_message.dart';

void main() {
  group('deleteUserAccountFailureMessage', () {
    test('maps failed-precondition to server message', () {
      final message = deleteUserAccountFailureMessage(
        FirebaseFunctionsException(
          code: 'failed-precondition',
          message:
              'You have active orders. Complete or cancel them before deleting your account.',
          details: null,
        ),
      );

      expect(
        message,
        'You have active orders. Complete or cancel them before deleting your account.',
      );
    });

    test('maps unauthenticated to sign-in copy', () {
      final message = deleteUserAccountFailureMessage(
        FirebaseFunctionsException(
          code: 'unauthenticated',
          message: 'Sign in required',
          details: null,
        ),
      );

      expect(message, 'Sign in required. Please log in and try again.');
    });

    test('falls back when server message is empty', () {
      final message = deleteUserAccountFailureMessage(
        FirebaseFunctionsException(
          code: 'internal',
          message: '',
          details: null,
        ),
      );

      expect(message, 'Could not delete account.');
    });
  });
}
