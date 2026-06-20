import 'dart:async';

/// Tracks idle time and invokes [onExpired] once when the timeout elapses.
///
/// Pure Dart — no Flutter or Riverpod dependencies.
class SessionInactivityTimer {
  SessionInactivityTimer({required this.onExpired});

  final void Function() onExpired;

  Duration _timeout = Duration.zero;
  DateTime? _lastActivityAt;
  Timer? _timer;
  bool _active = false;
  bool _hasExpired = false;

  bool get isActive => _active;

  void updateTimeout(Duration timeout) {
    _timeout = timeout;
    if (_active) {
      _scheduleTimer();
    }
  }

  void activate(Duration timeout) {
    _timeout = timeout;
    _active = true;
    _hasExpired = false;
    _lastActivityAt = DateTime.now();
    _scheduleTimer();
  }

  void deactivate() {
    _active = false;
    _cancelTimer();
    _lastActivityAt = null;
    _hasExpired = false;
  }

  void recordActivity() {
    if (!_active || _hasExpired) return;
    _lastActivityAt = DateTime.now();
    _scheduleTimer();
  }

  void onAppPaused() {
    _cancelTimer();
  }

  void onAppResumed() {
    if (!_active || _hasExpired || _lastActivityAt == null) return;

    final elapsed = DateTime.now().difference(_lastActivityAt!);
    if (elapsed >= _timeout) {
      _expire();
      return;
    }

    _scheduleTimer(remaining: _timeout - elapsed);
  }

  void dispose() {
    deactivate();
  }

  void _scheduleTimer({Duration? remaining}) {
    _cancelTimer();
    if (!_active || _lastActivityAt == null) return;

    final wait = remaining ?? _timeout;
    if (wait <= Duration.zero) {
      _expire();
      return;
    }

    _timer = Timer(wait, _expire);
  }

  void _expire() {
    if (!_active || _hasExpired) return;
    _hasExpired = true;
    _cancelTimer();
    onExpired();
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }
}
