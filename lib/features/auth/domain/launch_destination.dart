/// Where the unified launch screen routes after boot work completes.
enum LaunchDestination {
  /// Force-update gate is blocking or async boot work is still running.
  hold,

  /// First-time guest — full onboarding carousel.
  onboarding,

  /// Returning guest — skip onboarding.
  login,

  /// Signed-in buyer with incomplete registration.
  registrationLogin,

  /// Signed-in buyer ready for the dashboard.
  home,
}

LaunchDestination resolveLaunchDestination({
  required bool hasAuthUser,
  required bool profileKnown,
  required bool registrationComplete,
  required bool hasSeenOnboarding,
  required bool forceUpdateCheckPending,
  required bool forceUpdateRequired,
}) {
  if (forceUpdateCheckPending || forceUpdateRequired) {
    return LaunchDestination.hold;
  }

  if (!hasAuthUser) {
    return hasSeenOnboarding
        ? LaunchDestination.login
        : LaunchDestination.onboarding;
  }

  if (!profileKnown) return LaunchDestination.hold;

  if (!registrationComplete) return LaunchDestination.registrationLogin;

  return LaunchDestination.home;
}

String? launchRouteForDestination(LaunchDestination destination) {
  return switch (destination) {
    LaunchDestination.hold => null,
    LaunchDestination.onboarding => '/onboarding',
    LaunchDestination.login => '/login',
    LaunchDestination.registrationLogin => '/login',
    LaunchDestination.home => '/home',
  };
}
