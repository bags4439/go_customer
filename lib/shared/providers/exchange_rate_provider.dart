import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../models/exchange_rate_model.dart';
import 'firebase_providers.dart';

final exchangeRateProvider = FutureProvider<ExchangeRateModel>((ref) async {
  final snapshot = await ref.watch(firestoreProvider)
      .collection(FirestoreCollections.exchangeRates)
      .where('isCurrent', isEqualTo: true)
      .limit(1)
      .get();
  if (snapshot.docs.isEmpty) {
    return ExchangeRateModel(
      id: 'fallback',
      usdToGhs: 15.40,
      fetchedAt: DateTime.now(),
      isCurrent: true,
    );
  }
  return ExchangeRateModel.fromFirestore(snapshot.docs.first);
});
