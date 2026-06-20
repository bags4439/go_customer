import 'package:flutter_test/flutter_test.dart';

import 'package:go_customer/core/session/session_inactivity_timer.dart';

void main() {
  group('SessionInactivityTimer', () {
    test('expires after idle timeout', () {
      var expired = false;
      final timer = SessionInactivityTimer(onExpired: () => expired = true);

      timer.activate(const Duration(milliseconds: 50));
      expect(expired, isFalse);

      expectLater(
        Future<void>.delayed(const Duration(milliseconds: 80)),
        completes,
      ).then((_) {
        expect(expired, isTrue);
      });
    });

    test('recordActivity resets idle countdown', () async {
      var expired = false;
      final timer = SessionInactivityTimer(onExpired: () => expired = true);

      timer.activate(const Duration(milliseconds: 80));
      await Future<void>.delayed(const Duration(milliseconds: 40));
      timer.recordActivity();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(expired, isFalse);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(expired, isTrue);

      timer.dispose();
    });

    test('onAppResumed expires when background idle exceeded timeout', () {
      var expired = false;
      final timer = SessionInactivityTimer(onExpired: () => expired = true);

      timer.activate(const Duration(milliseconds: 30));
      timer.onAppPaused();
      timer.onAppResumed();
      expect(expired, isFalse);

      timer.dispose();
    });

    test('onAppResumed expires immediately when idle exceeded', () async {
      var expired = false;
      final timer = SessionInactivityTimer(onExpired: () => expired = true);

      timer.activate(const Duration(milliseconds: 20));
      await Future<void>.delayed(const Duration(milliseconds: 30));
      timer.onAppPaused();
      timer.onAppResumed();
      expect(expired, isTrue);

      timer.dispose();
    });

    test('deactivate prevents expiry', () async {
      var expired = false;
      final timer = SessionInactivityTimer(onExpired: () => expired = true);

      timer.activate(const Duration(milliseconds: 30));
      timer.deactivate();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(expired, isFalse);

      timer.dispose();
    });
  });
}
