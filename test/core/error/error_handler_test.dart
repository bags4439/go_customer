import 'package:flutter_test/flutter_test.dart';
import 'package:go_customer/core/error/error_handler.dart';
import 'package:go_customer/core/error/failures.dart';

void main() {
  group('shouldReportFailure', () {
    test('skips validation failures', () {
      expect(
        shouldReportFailure(
          const ValidationFailure(message: 'Invalid phone'),
        ),
        isFalse,
      );
    });

    test('skips network failures', () {
      expect(
        shouldReportFailure(
          const NetworkFailure(message: 'Offline'),
        ),
        isFalse,
      );
    });

    test('reports firestore failures', () {
      expect(
        shouldReportFailure(
          const FirestoreFailure(message: 'Permission denied'),
        ),
        isTrue,
      );
    });

    test('reports unexpected failures', () {
      expect(
        shouldReportFailure(
          const UnexpectedFailure(message: 'Unknown'),
        ),
        isTrue,
      );
    });
  });
}
