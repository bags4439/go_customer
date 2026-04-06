import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/models/currency_model.dart';
import 'firebase_providers.dart';

/// Active currencies from Firestore currencies
/// collection. Sorted client-side (avoids composite index).
/// Falls back to GHS + USD if Firestore fails.
final currenciesProvider =
    FutureProvider<List<CurrencyModel>>((ref) async {
  try {
    final snap = await ref
        .watch(firestoreProvider)
        .collection(FirestoreCollections.currencies)
        .where('isActive', isEqualTo: true)
        .get();

    final list = snap.docs
        .map(CurrencyModel.fromFirestore)
        .toList();

    list.sort((a, b) {
      final aOrder = _sortOrder(a.code);
      final bOrder = _sortOrder(b.code);
      return aOrder.compareTo(bOrder);
    });

    return list.isEmpty ? _fallback : list;
  } catch (_) {
    return _fallback;
  }
});

/// Fallback if Firestore is unreachable.
const _fallback = [
  CurrencyModel(
    code: 'GHS',
    symbol: 'GHS',
    name: 'Ghanaian Cedi',
    usdToRate: 15.40,
    decimalDigits: 0,
  ),
  CurrencyModel(
    code: 'USD',
    symbol: r'$',
    name: 'US Dollar',
    usdToRate: 1.0,
    decimalDigits: 0,
  ),
];

/// Returns a sort order for known codes.
/// Unknown codes go to the end.
int _sortOrder(String code) {
  switch (code) {
    case 'GHS':
      return 1;
    case 'USD':
      return 2;
    case 'EUR':
      return 3;
    case 'GBP':
      return 4;
    default:
      return 99;
  }
}
