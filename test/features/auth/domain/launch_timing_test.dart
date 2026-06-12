import 'package:flutter_test/flutter_test.dart';
import 'package:go_customer/features/auth/domain/launch_timing.dart';

void main() {
  group('LaunchTiming.departureDelay', () {
    test('zero when dwell and entrance are both satisfied', () {
      expect(
        LaunchTiming.departureDelay(
          elapsedSinceFirstPaint: const Duration(milliseconds: 800),
          entranceComplete: true,
          entranceProgress: 1,
        ),
        Duration.zero,
      );
    });

    test('waits for remaining dwell time', () {
      expect(
        LaunchTiming.departureDelay(
          elapsedSinceFirstPaint: const Duration(milliseconds: 200),
          entranceComplete: true,
          entranceProgress: 1,
        ),
        const Duration(milliseconds: 500),
      );
    });

    test('waits for entrance when dwell already met', () {
      expect(
        LaunchTiming.departureDelay(
          elapsedSinceFirstPaint: const Duration(milliseconds: 900),
          entranceComplete: false,
          entranceProgress: 0.5,
        ),
        const Duration(milliseconds: 400),
      );
    });
  });
}
