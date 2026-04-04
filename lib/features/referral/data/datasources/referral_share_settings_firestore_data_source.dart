import '../../core/constants/referral_firestore_keys.dart';

/// Extracts referral share settings from a pre-loaded `system_settings` map.
/// The map is loaded once by `systemSettingsProvider`.
class ReferralShareSettingsFirestoreDataSource {
  ReferralShareSettingsFirestoreDataSource();

  Map<String, dynamic> extractFromSettings(Map<String, dynamic> settings) {
    String? stringAt(String key) {
      final v = settings[key];
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    double? numAt(String key) {
      final v = settings[key];
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    String? firstStringAmong(List<String> keys) {
      for (final k in keys) {
        final s = stringAt(k);
        if (s != null) return s;
      }
      return null;
    }

    return {
      'referralDiscountGhs': numAt(ReferralFirestoreKeys.referralDiscountAmount),
      'appStoreUrl': firstStringAmong([
        ReferralFirestoreKeys.appStoreUrl,
        'iosAppUrl',
        'app_store_url',
      ]),
      'playstoreUrl': firstStringAmong([
        ReferralFirestoreKeys.playstoreUrl,
        'playStoreUrl',
        'googlePlayUrl',
        'androidAppUrl',
      ]),
      'websiteUrl': firstStringAmong([
        ReferralFirestoreKeys.websiteUrl,
        'webUrl',
        'siteUrl',
      ]),
    };
  }
}
