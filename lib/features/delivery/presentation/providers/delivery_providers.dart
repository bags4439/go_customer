import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/firebase_providers.dart';
import '../../data/datasources/delivery_firestore_data_source.dart';
import '../../data/repositories/delivery_repository_impl.dart';
import '../../domain/entities/delivery.dart';
import '../../domain/repositories/delivery_repository.dart';

final deliveryDataSourceProvider = Provider<DeliveryFirestoreDataSource>((ref) {
  return DeliveryFirestoreDataSource(
    ref.watch(firestoreProvider),
  );
});

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  return DeliveryRepositoryImpl(
    ref.watch(deliveryDataSourceProvider),
  );
});

final deliveryProvider =
    StreamProvider.family<Delivery?, String>((ref, orderId) {
  return ref.watch(deliveryRepositoryProvider).watchDelivery(orderId).map(
        (either) => either.fold((_) => null, (d) => d),
      );
});
