import 'package:flutter/material.dart';

import '../utils/crash_reporter.dart';
import 'failures.dart';

Future<void> reportFailure(Failure failure, [StackTrace? stackTrace]) async {
  await CrashReporter.reportError(
    failure,
    stackTrace: stackTrace ?? StackTrace.current,
    context: failure.message,
  );
}

String failureToUserMessage(Failure failure) {
  if (failure is ValidationFailure) return failure.message;
  if (failure is FirebaseAuthFailure) return failure.message;
  if (failure is AuthFailure) {
    return 'We could not verify your details. Please check and try again.';
  }
  if (failure is NetworkFailure) {
    return 'Connection issue. Please check your internet and try again.';
  }
  if (failure is FirestoreFailure || failure is StorageFailure) {
    return 'Something went wrong saving your data. Please try again.';
  }
  return 'Something went wrong. Please try again.';
}

Future<void> showFailureSnackBar(
  BuildContext context,
  Failure failure, {
  bool report = true,
}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(failureToUserMessage(failure))),
    );
  if (report) {
    await reportFailure(failure);
  }
}

