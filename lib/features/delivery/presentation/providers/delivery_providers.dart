import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/providers/firebase_providers.dart';
import '../../../../shared/providers/system_settings_provider.dart';
import '../../../orders/data/models/buyer_review_model.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../../payments/data/models/payment_request_model.dart';
import '../../core/constants/delivery_constants.dart';
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

/// Streams the existing buyer review
/// for a given order and buyer.
/// Returns null if no review submitted.
/// Family key: (orderId, buyerId)
final buyerReviewProvider =
    StreamProvider.family<BuyerReviewModel?, ({String orderId, String buyerId})>(
  (ref, params) {
    return ref
        .watch(deliveryRepositoryProvider)
        .watchReview(
          orderId: params.orderId,
          buyerId: params.buyerId,
        )
        .map(
          (either) => either.fold(
            (_) => null,
            (review) => review,
          ),
        );
  },
);

/// Delivery coordination fee in USD.
/// Read from system_settings
/// deliveryFee key.
/// Falls back to 0.0 if not set.
final deliveryServiceFeeProvider = FutureProvider<double>((ref) async {
  final settings = await ref.watch(systemSettingsProvider.future);
  return settings.numValue(
    DeliveryConstants.systemSettingsKeyDeliveryFee,
    fallback: DeliveryConstants.deliveryFeeFallbackUsd,
  );
});

/// Screen state for delivery route.
enum DeliveryScreenState {
  /// order.stageNumber < 9
  notAvailable,

  /// delivery doc is null —
  /// customer has not chosen yet
  choice,

  /// handledBy == 'agent' &&
  /// !paymentsCleared
  awaitingPaymentClearance,

  /// handledBy == 'agent' &&
  /// paymentsCleared && !hasLocation
  addressEntry,

  /// handledBy == 'agent' &&
  /// paymentsCleared && hasLocation
  /// && !isConfirmed
  locationSet,

  /// handledBy == 'self' &&
  /// !isConfirmed
  selfPickup,

  /// isConfirmed
  confirmed,
}

final deliveryScreenStateProvider =
    Provider.family<DeliveryScreenState, String>((ref, orderId) {
  final order = ref.watch(orderProvider(orderId)).valueOrNull;
  final delivery = ref.watch(deliveryProvider(orderId)).valueOrNull;

  // Gate on stageNumber
  if ((order?.stageNumber ?? 0) < 9) {
    return DeliveryScreenState.notAvailable;
  }

  // No delivery doc yet
  if (delivery == null) {
    return DeliveryScreenState.choice;
  }

  // Confirmed — both paths end here
  if (delivery.isConfirmed) {
    return DeliveryScreenState.confirmed;
  }

  // Self pickup path
  if (delivery.isSelfPickup) {
    return DeliveryScreenState.selfPickup;
  }

  // Agent path
  if (!delivery.isPaymentsCleared) {
    return DeliveryScreenState.awaitingPaymentClearance;
  }

  if (!delivery.hasLocation) {
    return DeliveryScreenState.addressEntry;
  }

  return DeliveryScreenState.locationSet;
});

/// Pending payment requests for
/// delivery stage (delivery_fee
/// and towing_fee types only).
final deliveryPendingPaymentsProvider =
    StreamProvider.family<List<PaymentRequestModel>, String>((ref, orderId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection(FirestoreCollections.paymentRequests)
      .where('orderId', isEqualTo: orderId)
      .where(
        'status',
        isEqualTo: FirestoreEnumValues.paymentRequestStatusPending,
      )
      .where('type', whereIn: [
        FirestoreEnumValues.paymentRequestTypeDeliveryFee,
        FirestoreEnumValues.paymentRequestTypeTowingFee,
      ])
      .snapshots()
      .map((snapshot) {
        final list = snapshot.docs
            .map(PaymentRequestModel.fromFirestore)
            .toList();
        list.sort((a, b) {
          final at = a.sentAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bt = b.sentAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bt.compareTo(at);
        });
        return list;
      });
});
