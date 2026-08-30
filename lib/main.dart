import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/session/session_inactivity_gate.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_entry_link.dart';
import 'core/utils/crash_reporter.dart';
import 'core/utils/onesignal_web_helper.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'features/force_update/presentation/widgets/force_update_gate.dart';
import 'features/notifications/onesignal/notification_onesignal_handler.dart';
import 'firebase_options.dart';
import 'router.dart';

Future<void> main() async {
  await _bootstrapApp();
}

Future<void> _bootstrapApp() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      await CrashReporter.initialise();
      _installErrorHandlers();

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

      runApp(
        const ProviderScope(child: CustomerApp()),
      );

      if (CrashReporter.shouldInitialiseSentry) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          unawaited(CrashReporter.initialiseSentryAfterFirstFrame());
        });
      }
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

void _installErrorHandlers() {
  FlutterError.onError = (errorDetails) {
    CrashReporter.reportError(
      errorDetails.exception,
      stackTrace: errorDetails.stack,
      context: 'FlutterError',
      fatal: true,
    );
    if (kDebugMode) {
      FlutterError.presentError(errorDetails);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    CrashReporter.reportError(
      error,
      stackTrace: stack,
      context: 'PlatformDispatcher',
      fatal: true,
    );
    return true;
  };
}

class CustomerApp extends ConsumerStatefulWidget {
  const CustomerApp({super.key});

  @override
  ConsumerState<CustomerApp> createState() => _CustomerAppState();
}

class _CustomerAppState extends ConsumerState<CustomerApp> {
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
    if (AppEntryLink.isPaystackCallback(uri)) return;
    if (!AppEntryLink.isAppEntry(uri)) return;

    final user = FirebaseAuth.instance.currentUser;
    router.go(user == null ? '/login' : '/home');
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(crashlyticsUserSyncProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.light(),
      routerConfig: router,
      builder: (context, child) {
        return ForceUpdateGate(
          child: SessionInactivityGate(
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
