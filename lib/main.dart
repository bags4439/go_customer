import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/crash_reporter.dart';
import 'core/utils/onesignal_web_helper.dart';
import 'features/notifications/onesignal/notification_onesignal_handler.dart';
import 'firebase_options.dart';
import 'router.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      await CrashReporter.initialise();

      FlutterError.onError = (errorDetails) {
        CrashReporter.reportError(
          errorDetails.exception,
          stackTrace: errorDetails.stack,
          context: 'FlutterError',
          fatal: true,
        );
      };

      PlatformDispatcher.instance.onError =
          (error, stack) {
        CrashReporter.reportError(
          error,
          stackTrace: stack,
          context: 'PlatformDispatcher',
          fatal: true,
        );
        return true;
      };

      if (!kIsWeb) {
        OneSignal.initialize(
          AppConstants.oneSignalAppId,
        );
        await OneSignal.Notifications
            .requestPermission(true);
        setupNotificationHandlers(router);
      } else {
        // Web: OneSignal JS SDK is already
        // initialised in index.html.
        // Request permission after the
        // app is rendered.
        Future.delayed(
          const Duration(seconds: 3),
          oneSignalWebRequestPermission,
        );
      }

      if (kDebugMode) {
        await FirebaseAuth.instance.setSettings(
          appVerificationDisabledForTesting: true,
        );
      }

      runApp(
        const ProviderScope(child: CustomerApp()),
      );
    },
    (error, stack) {
      CrashReporter.reportError(
        error,
        stackTrace: stack,
        context: 'runZonedGuarded',
        fatal: false,
      );
    },
  );
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
