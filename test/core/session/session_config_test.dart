import 'package:flutter_test/flutter_test.dart';

import 'package:go_customer/core/session/session_config.dart';
import 'package:go_customer/core/session/session_settings_keys.dart';

void main() {
  group('resolveSessionConfig', () {
    test('uses default when inactivityTimeout is missing', () {
      final config = resolveSessionConfig({});
      expect(config.inactivityTimeout, SessionDefaults.inactivityTimeout);
    });

    test('parses minutes from numeric value', () {
      final config = resolveSessionConfig({
        SessionSettingsKeys.inactivityTimeout: 10,
      });
      expect(config.inactivityTimeout, const Duration(minutes: 10));
    });

    test('parses minutes from string value', () {
      final config = resolveSessionConfig({
        SessionSettingsKeys.inactivityTimeout: '15',
      });
      expect(config.inactivityTimeout, const Duration(minutes: 15));
    });

    test('falls back when value is invalid', () {
      final config = resolveSessionConfig({
        SessionSettingsKeys.inactivityTimeout: 0,
      });
      expect(config.inactivityTimeout, SessionDefaults.inactivityTimeout);
    });

    test('clamps maximum minutes', () {
      final config = resolveSessionConfig({
        SessionSettingsKeys.inactivityTimeout: 9999,
      });
      expect(
        config.inactivityTimeout,
        const Duration(minutes: SessionDefaults.maxInactivityMinutes),
      );
    });
  });
}
