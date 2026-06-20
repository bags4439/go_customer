import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../router.dart';
import '../widgets/app_top_banner.dart';
import 'session_inactivity_timer.dart';
import 'session_settings_keys.dart';

/// Coordinates idle tracking with auth sign-out when the timer expires.
class SessionInactivityNotifier {
  SessionInactivityNotifier(this._ref) {
    _timer = SessionInactivityTimer(onExpired: _handleExpired);
  }

  final Ref _ref;
  late final SessionInactivityTimer _timer;
  bool _handlingExpiry = false;

  bool get isMonitoring => _timer.isActive;

  void enable(Duration timeout) {
    _timer.activate(timeout);
  }

  void disable() {
    _timer.deactivate();
  }

  void updateTimeout(Duration timeout) {
    _timer.updateTimeout(timeout);
  }

  void recordActivity() {
    _timer.recordActivity();
  }

  void onAppPaused() {
    _timer.onAppPaused();
  }

  void onAppResumed() {
    _timer.onAppResumed();
  }

  void dispose() {
    _timer.dispose();
  }

  Future<void> _handleExpired() async {
    if (_handlingExpiry) return;
    _handlingExpiry = true;

    try {
      disable();
      await _ref.read(authRepositoryProvider).signOut();
      router.go('/login');
      SchedulerBinding.instance.addPostFrameCallback((_) {
        showAppTopBanner(
          body: SessionMessages.sessionExpiredDueToInactivity,
          appearance: AppTopBannerAppearance.info,
          duration: const Duration(seconds: 4),
        );
      });
    } finally {
      _handlingExpiry = false;
    }
  }
}

final sessionInactivityNotifierProvider =
    Provider<SessionInactivityNotifier>((ref) {
  final notifier = SessionInactivityNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});
