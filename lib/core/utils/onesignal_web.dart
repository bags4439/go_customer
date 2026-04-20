// Web implementation of OneSignal
// JS interop helpers.
// Only compiled on web platform.
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

/// Log a user into OneSignal Web SDK
/// by their external user ID.
/// Must match the ID used on mobile
/// (Firebase UID).
void oneSignalWebLogin(String userId) {
  try {
    js.context.callMethod(
      'oneSignalLoginWeb',
      [userId],
    );
  } catch (_) {}
}

/// Log the current user out of
/// OneSignal Web SDK.
void oneSignalWebLogout() {
  try {
    js.context.callMethod(
      'oneSignalLogoutWeb',
      [],
    );
  } catch (_) {}
}

/// Request push notification
/// permission via OneSignal Web SDK.
void oneSignalWebRequestPermission() {
  try {
    js.context.callMethod(
      'oneSignalRequestPermissionWeb',
      [],
    );
  } catch (_) {}
}
