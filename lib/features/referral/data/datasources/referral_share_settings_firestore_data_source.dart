import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../core/constants/referral_firestore_keys.dart';

/// Loads referral-related settings from `system_settings`.
///
/// Supports two shapes:
/// 1. **Singleton app config** — one document with top-level fields such as
///    `referralDiscountAmount`, `appStoreUrl`, `playstoreUrl`, `websiteUrl`
///    (your current Firestore layout).
/// 2. **Legacy rows** — documents with `key` + `value` (and optional `url` / `link`),
///    plus `doc(settingKey)` fallback.
class ReferralShareSettingsFirestoreDataSource {
  ReferralShareSettingsFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(FirestoreCollections.systemSettings);

  /// Legacy: `{ key: 'depositPercentage', value: ... }` style rows.
  static bool _isLegacyKeyValueRow(Map<String, dynamic> data) {
    return data.containsKey('key') &&
        data['key'] is String &&
        data.containsKey('value');
  }

  /// Flat app config document (no `key`/`value` row shape).
  static bool _isFlatAppConfigDoc(Map<String, dynamic> data) {
    if (_isLegacyKeyValueRow(data)) return false;
    return data.containsKey(ReferralFirestoreKeys.referralDiscountAmount) ||
        data.containsKey(ReferralFirestoreKeys.appStoreUrl) ||
        data.containsKey(ReferralFirestoreKeys.playstoreUrl) ||
        data.containsKey(ReferralFirestoreKeys.websiteUrl);
  }

  static String? _stringField(Map<String, dynamic> data, String field) {
    final v = data[field];
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static double? _numField(Map<String, dynamic> data, String field) {
    final v = data[field];
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim());
    return null;
  }

  Map<String, dynamic> _mergedFromFlat(Map<String, dynamic> data) {
    return {
      'referralDiscountGhs':
          _numField(data, ReferralFirestoreKeys.referralDiscountAmount),
      'appStoreUrl': _stringField(data, ReferralFirestoreKeys.appStoreUrl),
      'playstoreUrl': _stringField(data, ReferralFirestoreKeys.playstoreUrl),
      'websiteUrl': _stringField(data, ReferralFirestoreKeys.websiteUrl),
    };
  }

  Future<Map<String, dynamic>?> _loadDocBySettingKey(String key) async {
    try {
      final q = await _col.where('key', isEqualTo: key).limit(1).get();
      if (q.docs.isNotEmpty) return q.docs.first.data();
      final d = await _col.doc(key).get();
      if (d.exists && d.data() != null) return d.data();
      return null;
    } catch (_) {
      return null;
    }
  }

  dynamic _extractValue(Map<String, dynamic>? data) {
    if (data == null) return null;
    return data['value'] ??
        data['url'] ??
        data['link'] ??
        data['stringValue'];
  }

  Future<double?> _numByKey(String key) async {
    try {
      final raw = _extractValue(await _loadDocBySettingKey(key));
      if (raw == null) return null;
      if (raw is num) return raw.toDouble();
      if (raw is String) return double.tryParse(raw.trim());
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _stringByKey(String key) async {
    try {
      final raw = _extractValue(await _loadDocBySettingKey(key));
      if (raw == null) return null;
      final s = raw.toString().trim();
      return s.isEmpty ? null : s;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _firstStringByKeys(List<String> keys) async {
    for (final k in keys) {
      final s = await _stringByKey(k);
      if (s != null && s.isNotEmpty) return s;
    }
    return null;
  }

  Future<Map<String, dynamic>> _fetchFromLegacyKeyValueDocs() async {
    final discount =
        await _numByKey(ReferralFirestoreKeys.referralDiscountAmount);
    final appStore = await _firstStringByKeys([
      ReferralFirestoreKeys.appStoreUrl,
      'iosAppUrl',
      'app_store_url',
    ]);
    final play = await _firstStringByKeys([
      ReferralFirestoreKeys.playstoreUrl,
      'playStoreUrl',
      'googlePlayUrl',
      'androidAppUrl',
    ]);
    final web = await _firstStringByKeys([
      ReferralFirestoreKeys.websiteUrl,
      'webUrl',
      'siteUrl',
    ]);

    return {
      'referralDiscountGhs': discount,
      'appStoreUrl': appStore,
      'playstoreUrl': play,
      'websiteUrl': web,
    };
  }

  Future<Map<String, dynamic>> fetchRaw() async {
    try {
      final snapshot = await _col.get();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (_isFlatAppConfigDoc(data)) {
          return _mergedFromFlat(data);
        }
      }
    } catch (_) {
      // Fall through to legacy reads.
    }

    return _fetchFromLegacyKeyValueDocs();
  }
}
