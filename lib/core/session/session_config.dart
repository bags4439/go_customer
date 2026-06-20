import 'session_settings_keys.dart';

/// Resolved buyer session policy from remote settings + code defaults.
class SessionConfig {
  const SessionConfig({required this.inactivityTimeout});

  final Duration inactivityTimeout;
}

/// Merges [settings] from `system_settings` with [SessionDefaults].
SessionConfig resolveSessionConfig(Map<String, dynamic> settings) {
  return SessionConfig(
    inactivityTimeout: _resolveInactivityTimeout(settings),
  );
}

Duration _resolveInactivityTimeout(Map<String, dynamic> settings) {
  final raw = settings[SessionSettingsKeys.inactivityTimeout];
  if (raw == null) return SessionDefaults.inactivityTimeout;

  num? minutes;
  if (raw is num) {
    minutes = raw;
  } else {
    minutes = num.tryParse(raw.toString().trim());
  }

  if (minutes == null || minutes < SessionDefaults.minInactivityMinutes) {
    return SessionDefaults.inactivityTimeout;
  }

  final clamped = minutes.clamp(
    SessionDefaults.minInactivityMinutes.toDouble(),
    SessionDefaults.maxInactivityMinutes.toDouble(),
  );

  return Duration(minutes: clamped.round());
}
