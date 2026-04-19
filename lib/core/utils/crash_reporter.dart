import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Central crash reporting utility.
/// All Firebase Crashlytics calls go through
/// this class — never call
/// FirebaseCrashlytics.instance directly
/// outside of main.dart initialisation.
///
/// Disabled entirely in debug mode so
/// development errors do not pollute the
/// Crashlytics dashboard.
class CrashReporter {
  CrashReporter._();

  static FirebaseCrashlytics get _instance =>
      FirebaseCrashlytics.instance;

  /// Call once after Firebase.initializeApp().
  /// Enables collection in release/profile,
  /// disables in debug.
  static Future<void> initialise() async {
    if (kIsWeb) return;
    await _instance.setCrashlyticsCollectionEnabled(
      true,
    );
  }

  /// Set the current user so crashes are
  /// attributable to a specific account.
  /// Call after successful login and after
  /// profile is loaded.
  /// Pass null to clear (e.g. on sign-out).
  static Future<void> setUser(String? userId) async {
    if (kIsWeb) return;
    if (kDebugMode) return;
    await _instance.setUserIdentifier(
      userId ?? '',
    );
  }

  /// Report a caught error with optional
  /// stack trace and context label.
  /// Use for errors you catch but still want
  /// tracked — e.g. failed API calls,
  /// Firestore errors, unexpected states.
  static Future<void> reportError(
    Object error, {
    StackTrace? stackTrace,
    String? context,
    bool fatal = false,
  }) async {
    if (kIsWeb) return;
    if (kDebugMode) {
      debugPrint(
        '[CrashReporter] ${context ?? ''} $error\n$stackTrace',
      );
      return;
    }
    if (context != null) {
      await _instance.log(context);
    }
    await _instance.recordError(
      error,
      stackTrace,
      fatal: fatal,
    );
  }

  /// Log a breadcrumb message — appears in
  /// the Crashlytics log tab alongside
  /// crash reports.
  static void log(String message) {
    if (kIsWeb) return;
    if (kDebugMode) return;
    _instance.log(message);
  }

  /// Set a custom key-value pair visible
  /// in the Crashlytics dashboard.
  /// Useful for recording app state at
  /// time of crash.
  static Future<void> setCustomKey(
    String key,
    Object value,
  ) async {
    if (kIsWeb) return;
    if (kDebugMode) return;
    await _instance.setCustomKey(key, value);
  }
}
