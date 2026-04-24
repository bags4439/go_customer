import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/firebase_providers.dart';
import '../../../orders/presentation/providers/order_timeline_providers.dart';
import '../../data/datasources/shipping_firestore_data_source.dart';
import '../../domain/entities/shipping.dart';

/// Screen state derived from shipping.status.
enum ShippingScreenState {
  notArranged,
  booked,
  inTransit,
  arrived,
  released,
}

final shippingDataSourceProvider = Provider<ShippingFirestoreDataSource>((ref) {
  return ShippingFirestoreDataSource(ref.watch(firestoreProvider));
});

final shippingProvider =
    StreamProvider.family<Shipping?, String>((ref, orderId) {
  return ref.watch(shippingDataSourceProvider).watchShipping(orderId);
});

/// Client-side progress. Use Firestore journeyProgressPct as fallback when
/// timestamps not yet available.
double computeProgress(Shipping shipping) {
  if (shipping.actualArrival != null) return 100.0;
  if (shipping.actualDeparture == null) return 0.0;
  final estimatedArrival = shipping.estimatedArrival;
  if (estimatedArrival == null) return 0.0;
  final total = estimatedArrival.difference(shipping.actualDeparture!).inMinutes;
  final elapsed = DateTime.now().difference(shipping.actualDeparture!).inMinutes;
  if (total <= 0) return 0.0;
  final pct = (elapsed / total * 100).clamp(0.0, 99.0);
  return pct;
}

final journeyProgressProvider = Provider.family<double, String>((ref, orderId) {
  final shipping = ref.watch(shippingProvider(orderId)).valueOrNull;
  if (shipping == null) return 0.0;
  final computed = computeProgress(shipping);
  final fromFirestore = shipping.journeyProgressPct;
  if (shipping.actualDeparture != null && shipping.estimatedArrival != null) {
    return computed;
  }
  return fromFirestore ?? computed;
});

final shippingScreenStateProvider =
    Provider.family<ShippingScreenState, String>((ref, orderId) {
  final shipping = ref.watch(orderShippingProvider(orderId)).valueOrNull;
  if (shipping == null) return ShippingScreenState.notArranged;
  switch (shipping.status.firestoreValue) {
    case 'pending':
    case 'booked':
      return ShippingScreenState.booked;
    case 'departed':
    case 'in_transit':
      return ShippingScreenState.inTransit;
    case 'arrived':
      return ShippingScreenState.arrived;
    case 'released':
      return ShippingScreenState.released;
    default:
      return ShippingScreenState.booked;
  }
});
