import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/models/currency_model.dart';
import 'firebase_providers.dart';

const _fallbackCurrencies = [
  CurrencyModel(code: 'GHS', symbol: '₵', name: 'Ghanaian Cedi'),
  CurrencyModel(code: 'USD', symbol: r'$', name: 'US Dollar'),
];

/// Active currencies from Firestore, ordered by [sortOrder].
/// Falls back to GHS + USD if the query fails or returns nothing.
final currenciesProvider = FutureProvider<List<CurrencyModel>>((ref) async {
  try {
    final snap = await ref.watch(firestoreProvider)
        .collection(FirestoreCollections.currencies)
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .get();
    final list =
        snap.docs.map(CurrencyModel.fromFirestore).toList();
    return list.isEmpty ? _fallbackCurrencies : list;
  } catch (_) {
    return _fallbackCurrencies;
  }
});
