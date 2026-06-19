import 'package:cloud_functions/cloud_functions.dart';

/// Maps [FirebaseFunctionsException] from `deleteUserAccount` to user-facing copy.
String deleteUserAccountFailureMessage(FirebaseFunctionsException e) {
  final serverMessage = e.message?.trim();
  return switch (e.code) {
    'unauthenticated' => 'Sign in required. Please log in and try again.',
    'permission-denied' => serverMessage?.isNotEmpty == true
        ? serverMessage!
        : 'You do not have permission to delete this account.',
    'not-found' => 'Account not found.',
    'failed-precondition' => serverMessage?.isNotEmpty == true
        ? serverMessage!
        : 'Your account cannot be deleted right now.',
    'invalid-argument' => serverMessage?.isNotEmpty == true
        ? serverMessage!
        : 'Invalid request. Please try again.',
    _ => serverMessage?.isNotEmpty == true
        ? serverMessage!
        : 'Could not delete account.',
  };
}
