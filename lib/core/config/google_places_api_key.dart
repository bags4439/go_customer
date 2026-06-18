import 'package:flutter/foundation.dart';

/// Firebase auto-created Google Cloud API keys, restricted per platform in GCP.
///
/// - [browser] — HTTP referrer restriction (`https://app.whiplyn.com/*`, localhost)
/// - [android] — package `com.velocitech.go_customer` + SHA-1
/// - [ios] — iOS bundle identifier
class GooglePlacesApiKey {
  GooglePlacesApiKey._();

  static const String browser =
      'AIzaSyCqv6Co9kCj9dEsdZcPAP2CGV17rcH6cyE';

  static const String android =
      'AIzaSyC9KM4yzaxzGWnzwJhiQWjta7Z7oORdlcg';

  static const String ios = 'AIzaSyCu5zmIP82grGRGxcp_PbHBlykGMR_uVgk';

  /// Key for the current platform (Places / Geocoding REST from the client).
  static String get current {
    if (kIsWeb) return browser;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return browser;
    }
  }

  static bool get isConfigured => current.isNotEmpty;
}
