/// Firestore `system_settings` keys for buyer session behaviour.
abstract final class SessionSettingsKeys {
  static const String inactivityTimeout = 'inactivityTimeout';
}

/// Code fallbacks when [SessionSettingsKeys.inactivityTimeout] is missing or invalid.
abstract final class SessionDefaults {
  static const Duration inactivityTimeout = Duration(minutes: 5);
  static const int minInactivityMinutes = 1;
  static const int maxInactivityMinutes = 120;
}

/// Copy shown after an inactivity sign-out.
abstract final class SessionMessages {
  static const String sessionExpiredDueToInactivity =
      'Your session expired due to inactivity. Please sign in again.';
}
