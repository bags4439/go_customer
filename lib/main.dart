import 'dart:async';

import 'package:app_links/app_links.dart';
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
import 'features/force_update/presentation/widgets/force_update_gate.dart';
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

class CustomerApp extends StatefulWidget {
  const CustomerApp({super.key});

  @override
  State<CustomerApp> createState() => _CustomerAppState();
}

class _CustomerAppState extends State<CustomerApp> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _sub = _appLinks.uriLinkStream.listen(
      _onLink,
      onError: (err) {
        debugPrint('[DeepLink] error: $err');
      },
    );

    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        _onLink(initial);
      }
    } catch (e) {
      debugPrint('[DeepLink] initial link error: $e');
    }
  }

  void _onLink(Uri uri) {
    debugPrint('[DeepLink] received: $uri');
    // autoimportgh://payment/callback — the processing screen is already
    // watching Firestore. No navigation needed here. The app simply comes to
    // foreground.
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.light(),
      routerConfig: router,
      builder: (context, child) {
        return ForceUpdateGate(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
