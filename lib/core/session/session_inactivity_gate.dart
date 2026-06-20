import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/force_update/presentation/providers/force_update_providers.dart';
import '../router/app_router_refresh.dart';
import '../../router.dart';
import 'session_inactivity_notifier.dart';
import 'session_inactivity_providers.dart';

/// Observes user activity and app lifecycle to enforce session inactivity timeout.
class SessionInactivityGate extends ConsumerStatefulWidget {
  const SessionInactivityGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SessionInactivityGate> createState() =>
      _SessionInactivityGateState();
}

class _SessionInactivityGateState extends ConsumerState<SessionInactivityGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    appRouterRefresh.addListener(_syncMonitoring);
    router.routerDelegate.addListener(_onRouteChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncMonitoring());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    appRouterRefresh.removeListener(_syncMonitoring);
    router.routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final notifier = ref.read(sessionInactivityNotifierProvider);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        notifier.onAppPaused();
      case AppLifecycleState.resumed:
        notifier.onAppResumed();
      case AppLifecycleState.inactive:
        break;
    }
  }

  void _onRouteChanged() {
    ref.read(sessionInactivityNotifierProvider).recordActivity();
  }

  void _syncMonitoring() {
    if (!mounted) return;

    final notifier = ref.read(sessionInactivityNotifierProvider);
    final timeout = ref.read(sessionConfigProvider).inactivityTimeout;
    final authUid = ref.read(authStateProvider).value;
    final registrationComplete = appRouterRefresh.registrationComplete;
    final forceUpdateBlocked = _isForceUpdateBlocking(ref);

    final shouldMonitor =
        authUid != null && registrationComplete && !forceUpdateBlocked;

    if (!shouldMonitor) {
      notifier.disable();
      return;
    }

    if (notifier.isMonitoring) {
      notifier.updateTimeout(timeout);
    } else {
      notifier.enable(timeout);
    }
  }

  bool _isForceUpdateBlocking(WidgetRef ref) {
    if (kIsWeb) return false;
    return ref.read(forceUpdateRequirementProvider).valueOrNull?.isRequired ??
        false;
  }

  void _recordActivity() {
    if (!_shouldRecordActivity) return;
    ref.read(sessionInactivityNotifierProvider).recordActivity();
  }

  bool get _shouldRecordActivity {
    final authUid = ref.read(authStateProvider).value;
    final registrationComplete = appRouterRefresh.registrationComplete;
    final forceUpdateBlocked = _isForceUpdateBlocking(ref);
    return authUid != null && registrationComplete && !forceUpdateBlocked;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionConfigProvider, (_, __) => _syncMonitoring());
    ref.listen(authStateProvider, (_, __) => _syncMonitoring());
    ref.listen(forceUpdateRequirementProvider, (_, __) => _syncMonitoring());

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification ||
            notification is UserScrollNotification) {
          _recordActivity();
        }
        return false;
      },
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _recordActivity(),
        child: widget.child,
      ),
    );
  }
}
