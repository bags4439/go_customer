import 'package:flutter_test/flutter_test.dart';
import 'package:go_customer/features/auth/domain/launch_destination.dart';

void main() {
  group('resolveLaunchDestination', () {
    test('holds while force update check is pending', () {
      expect(
        resolveLaunchDestination(
          hasAuthUser: false,
          profileKnown: true,
          registrationComplete: false,
          hasSeenOnboarding: false,
          forceUpdateCheckPending: true,
          forceUpdateRequired: false,
        ),
        LaunchDestination.hold,
      );
    });

    test('holds when force update is required', () {
      expect(
        resolveLaunchDestination(
          hasAuthUser: true,
          profileKnown: true,
          registrationComplete: true,
          hasSeenOnboarding: true,
          forceUpdateCheckPending: false,
          forceUpdateRequired: true,
        ),
        LaunchDestination.hold,
      );
    });

    test('first-time guest goes to onboarding', () {
      expect(
        resolveLaunchDestination(
          hasAuthUser: false,
          profileKnown: true,
          registrationComplete: false,
          hasSeenOnboarding: false,
          forceUpdateCheckPending: false,
          forceUpdateRequired: false,
        ),
        LaunchDestination.onboarding,
      );
    });

    test('returning guest goes to login', () {
      expect(
        resolveLaunchDestination(
          hasAuthUser: false,
          profileKnown: true,
          registrationComplete: false,
          hasSeenOnboarding: true,
          forceUpdateCheckPending: false,
          forceUpdateRequired: false,
        ),
        LaunchDestination.login,
      );
    });

    test('signed-in buyer waits for profile', () {
      expect(
        resolveLaunchDestination(
          hasAuthUser: true,
          profileKnown: false,
          registrationComplete: false,
          hasSeenOnboarding: true,
          forceUpdateCheckPending: false,
          forceUpdateRequired: false,
        ),
        LaunchDestination.hold,
      );
    });

    test('signed-in incomplete registration goes to login', () {
      expect(
        resolveLaunchDestination(
          hasAuthUser: true,
          profileKnown: true,
          registrationComplete: false,
          hasSeenOnboarding: true,
          forceUpdateCheckPending: false,
          forceUpdateRequired: false,
        ),
        LaunchDestination.registrationLogin,
      );
    });

    test('signed-in complete buyer goes to home', () {
      expect(
        resolveLaunchDestination(
          hasAuthUser: true,
          profileKnown: true,
          registrationComplete: true,
          hasSeenOnboarding: false,
          forceUpdateCheckPending: false,
          forceUpdateRequired: false,
        ),
        LaunchDestination.home,
      );
    });
  });

  group('launchRouteForDestination', () {
    test('maps destinations to routes', () {
      expect(launchRouteForDestination(LaunchDestination.home), '/home');
      expect(launchRouteForDestination(LaunchDestination.login), '/login');
      expect(
        launchRouteForDestination(LaunchDestination.onboarding),
        '/onboarding',
      );
      expect(launchRouteForDestination(LaunchDestination.hold), isNull);
    });
  });
}
