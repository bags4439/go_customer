import 'package:flutter/foundation.dart';

import '../../../shared/providers/system_settings_provider.dart';
import '../../referral/core/constants/referral_firestore_keys.dart';
import '../core/constants/force_update_settings_keys.dart';

/// Reads force-update fields from a pre-loaded [system_settings] map.
class ForceUpdateConfigResolver {
  const ForceUpdateConfigResolver();

  String? minimumVersionForPlatform(
    Map<String, dynamic> settings,
    TargetPlatform platform,
  ) {
    switch (platform) {
      case TargetPlatform.iOS:
        return settings.stringValue(ForceUpdateSettingsKeys.iosVersion);
      case TargetPlatform.android:
        return settings.stringValue(ForceUpdateSettingsKeys.androidVersion);
      default:
        return null;
    }
  }

  String? storeUrlForPlatform(
    Map<String, dynamic> settings,
    TargetPlatform platform,
  ) {
    switch (platform) {
      case TargetPlatform.iOS:
        return _firstStringAmong(settings, [
          ReferralFirestoreKeys.appStoreUrl,
          'iosAppUrl',
          'app_store_url',
        ]);
      case TargetPlatform.android:
        return _firstStringAmong(settings, [
          ReferralFirestoreKeys.playstoreUrl,
          'playStoreUrl',
          'googlePlayUrl',
          'androidAppUrl',
        ]);
      default:
        return null;
    }
  }

  String storeLabelForPlatform(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.iOS:
        return 'App Store';
      case TargetPlatform.android:
        return 'Google Play';
      default:
        return 'app store';
    }
  }

  bool isSupportedNativePlatform(TargetPlatform platform) {
    return platform == TargetPlatform.iOS ||
        platform == TargetPlatform.android;
  }

  String? _firstStringAmong(
    Map<String, dynamic> settings,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = settings.stringValue(key);
      if (value != null) return value;
    }
    return null;
  }
}
