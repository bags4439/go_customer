/// Timing for the unified launch screen — avoids flicker while staying snappy.
abstract final class LaunchTiming {
  LaunchTiming._();

  /// Minimum time the launch screen stays visible after first paint.
  static const Duration minDwell = Duration(milliseconds: 700);

  /// Logo entrance — departure waits until this completes.
  static const Duration entrance = Duration(milliseconds: 800);

  /// Fade-out before navigating to the next screen.
  static const Duration exitFade = Duration(milliseconds: 280);

  /// Remaining wait before departure once boot work is ready.
  static Duration departureDelay({
    required Duration elapsedSinceFirstPaint,
    required bool entranceComplete,
    required double entranceProgress,
  }) {
    if (entranceComplete && elapsedSinceFirstPaint >= minDwell) {
      return Duration.zero;
    }

    final dwellRemaining = minDwell - elapsedSinceFirstPaint;
    final entranceRemaining = entranceComplete
        ? Duration.zero
        : Duration(
            milliseconds: (entrance.inMilliseconds * (1 - entranceProgress))
                .clamp(0, entrance.inMilliseconds)
                .round(),
          );

    final remaining = dwellRemaining > entranceRemaining
        ? dwellRemaining
        : entranceRemaining;

    return remaining.isNegative ? Duration.zero : remaining;
  }
}
