import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../constants/app_constants.dart';

/// Central crash reporting utility.
///
/// - Web (profile/release): Sentry
/// - Android/iOS (profile/release): Firebase Crashlytics
/// - Debug: console only on all platforms
///
/// Never call [FirebaseCrashlytics.instance] or Sentry APIs directly
/// outside of [main] initialisation.
class CrashReporter {
  CrashReporter._();

  static FirebaseCrashlytics get _crashlytics =>
      FirebaseCrashlytics.instance;

  /// Whether Sentry should be initialised in [main].
  static bool get shouldInitialiseSentry => kIsWeb && !kDebugMode;

  static bool get _reportsEnabled => !kDebugMode;

  static bool get _useSentry => kIsWeb;

  static bool get _useCrashlytics => !kIsWeb;

  /// Sentry options — only called from [SentryFlutter.init] on web.
  static void configureSentry(SentryFlutterOptions options) {
    options.dsn = AppConstants.sentryDsn;
    options.environment = kReleaseMode ? 'production' : 'profile';
    options.sendDefaultPii = false;
    options.tracesSampleRate = 0.2;
    options.beforeSend = (event, hint) {
      if (kDebugMode) return null;
      return event;
    };
  }

  /// Call once after [Firebase.initializeApp].
  static Future<void> initialise() async {
    if (_useCrashlytics) {
      await _crashlytics.setCrashlyticsCollectionEnabled(
        _reportsEnabled,
      );
    }
  }

  /// Set the current user so crashes are attributable to a specific account.
  /// Pass null to clear (e.g. on sign-out).
  static Future<void> setUser(String? userId) async {
    if (!_reportsEnabled) return;

    if (_useSentry) {
      await Sentry.configureScope((scope) {
        scope.setUser(
          userId == null ? null : SentryUser(id: userId),
        );
      });
      return;
    }

    await _crashlytics.setUserIdentifier(userId ?? '');
  }

  /// Report a caught error with optional stack trace and context label.
  static Future<void> reportError(
    Object error, {
    StackTrace? stackTrace,
    String? context,
    bool fatal = false,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '[CrashReporter] ${context ?? ''} $error\n$stackTrace',
      );
      return;
    }

    if (_useSentry) {
      if (context != null) {
        Sentry.addBreadcrumb(Breadcrumb(message: context));
      }
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.level =
              fatal ? SentryLevel.fatal : SentryLevel.error;
          if (context != null) {
            scope.setTag('context', context);
          }
        },
      );
      return;
    }

    if (context != null) {
      await _crashlytics.log(context);
    }
    await _crashlytics.recordError(
      error,
      stackTrace,
      fatal: fatal,
    );
  }

  /// Log a breadcrumb message alongside crash reports.
  static void log(String message) {
    if (!_reportsEnabled) return;

    if (_useSentry) {
      Sentry.addBreadcrumb(Breadcrumb(message: message));
      return;
    }

    _crashlytics.log(message);
  }

  /// Set a custom key-value pair visible in the error dashboard.
  static Future<void> setCustomKey(
    String key,
    Object value,
  ) async {
    if (!_reportsEnabled) return;

    if (_useSentry) {
      await Sentry.configureScope((scope) {
        scope.setTag(key, value.toString());
      });
      return;
    }

    await _crashlytics.setCustomKey(key, value);
  }
}
