import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import 'firebase_providers.dart';

/// Reads the entire `system_settings` collection once and returns a merged
/// key→value map.
///
/// Supports:
/// - Legacy rows: documents with non-empty `key` and a value from `value`,
///   `url`, `link`, or `stringValue`.
/// - Flat config documents: documents without a `key` field — scalar
///   top-level fields are merged into the map (e.g. referral singleton doc).
///
/// Riverpod caches this provider for the app session unless invalidated.
final systemSettingsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final firestore = ref.watch(firestoreProvider);

  try {
    final snap = await firestore
        .collection(FirestoreCollections.systemSettings)
        .get();

    final map = <String, dynamic>{};
    for (final doc in snap.docs) {
      final data = doc.data();
      final key = data['key'] as String?;
      if (key != null && key.isNotEmpty) {
        final value =
            data['value'] ?? data['url'] ?? data['link'] ?? data['stringValue'];
        map[key] = value;
      } else {
        for (final e in data.entries) {
          final v = e.value;
          if (v == null || v is Map) continue;
          map[e.key] = v;
        }
      }
    }
    return map;
  } catch (_) {
    return <String, dynamic>{};
  }
});

/// Typed helpers for [systemSettingsProvider] maps.
extension SystemSettingsMapX on Map<String, dynamic> {
  String? stringValue(String key) {
    final v = this[key];
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  double numValue(String key, {double fallback = 0}) {
    final v = this[key];
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }
}
