import 'package:cloud_firestore/cloud_firestore.dart';

/// Whether an order document should appear in buyer and agent lists.
bool isOrderVisibleFromMap(Map<String, dynamic> data) {
  return data['hiddenAt'] == null;
}

/// Parses [hiddenAt] from a Firestore order map.
DateTime? hiddenAtFromMap(Map<String, dynamic> data) {
  final raw = data['hiddenAt'];
  if (raw is Timestamp) return raw.toDate();
  return null;
}
