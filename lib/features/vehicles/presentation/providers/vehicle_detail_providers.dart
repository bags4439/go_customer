import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/providers/exchange_rate_provider.dart';
import '../../../../shared/providers/firebase_providers.dart';
import '../../../vehicle_options/data/models/vehicle_option_model.dart';
import '../../data/datasources/vehicle_firestore_data_source.dart';
import '../../data/repositories/vehicle_repository_impl.dart';
import '../../domain/entities/vehicle_option_entity.dart';
import '../../domain/repositories/vehicle_repository.dart';

final vehicleFirestoreDataSourceProvider = Provider<VehicleFirestoreDataSource>(
  (ref) {
    return VehicleFirestoreDataSource(ref.watch(firestoreProvider));
  },
);

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepositoryImpl(ref.watch(vehicleFirestoreDataSourceProvider));
});

final vehicleOptionProvider =
    FutureProvider.family<VehicleOptionEntity?, String>((
      ref,
      vehicleOptionId,
    ) async {
      return ref
          .watch(vehicleRepositoryProvider)
          .getVehicleOption(vehicleOptionId);
    });

/// Real-time vehicle option (e.g. chat vehicle card).
final vehicleOptionStreamProvider =
    StreamProvider.family<VehicleOptionEntity?, String>((ref, vehicleOptionId) {
      final firestore = ref.watch(firestoreProvider);
      return firestore
          .collection(FirestoreCollections.vehicleOptions)
          .doc(vehicleOptionId)
          .snapshots()
          .map(
            (snap) => snap.exists
                ? VehicleOptionModel.fromFirestore(snap).toEntity()
                : null,
          );
    });

/// Read-only cost breakdown (no max bid — auction/BIN list price only).
class ReadOnlyVehicleCost {
  final bool isBuyItNow;
  final double? listPriceUsd;
  final double premiumUsd;
  final double fixedFeesUsd;
  final double totalUsd;
  final double? rate;

  const ReadOnlyVehicleCost({
    required this.isBuyItNow,
    required this.listPriceUsd,
    required this.premiumUsd,
    required this.fixedFeesUsd,
    required this.totalUsd,
    required this.rate,
  });

  bool get isRateAvailable => rate != null && rate! > 0;

  String? ghsText(double usdAmount) {
    final r = rate;
    if (r == null || r <= 0) return null;
    return CurrencyFormatter.formatGhs(usdAmount * r);
  }

  static ReadOnlyVehicleCost? fromOption(
    VehicleOptionEntity? option,
    double? rate,
  ) {
    if (option == null) return null;
    final pct = (option.buyersPremiumPct ?? 0) / 100.0;
    final fixed = option.fixedPlatformFeesUsd ?? 0.0;
    final bin = option.isBuyItNow;
    final double? listUsd = bin
        ? (option.buyItNowPriceUsd ?? option.auctionPriceUsd)
        : option.auctionPriceUsd;
    if (listUsd == null) return null;
    final premium = listUsd * pct;
    final total = listUsd + premium + fixed;
    return ReadOnlyVehicleCost(
      isBuyItNow: bin,
      listPriceUsd: listUsd,
      premiumUsd: premium,
      fixedFeesUsd: fixed,
      totalUsd: total,
      rate: rate,
    );
  }
}

final readOnlyVehicleCostProvider =
    Provider.family<ReadOnlyVehicleCost?, String>((ref, vehicleOptionId) {
      final option = ref
          .watch(vehicleOptionStreamProvider(vehicleOptionId))
          .valueOrNull;
      final rate = ref.watch(exchangeRateProvider).valueOrNull?.usdToGhs;
      return ReadOnlyVehicleCost.fromOption(option, rate);
    });

/// Agent info for vehicle detail (name, initials) from vehicle's agentId.
class AgentForVehicleView {
  final String agentId;
  final String fullName;
  final String? photoUrl;

  const AgentForVehicleView({
    required this.agentId,
    required this.fullName,
    this.photoUrl,
  });

  String get firstName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? fullName : parts.first;
  }

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'AG';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}

final agentForVehicleProvider =
    FutureProvider.family<AgentForVehicleView?, String>((
      ref,
      vehicleOptionId,
    ) async {
      final option = ref
          .watch(vehicleOptionStreamProvider(vehicleOptionId))
          .valueOrNull;
      final agentId = option?.agentId;
      if (agentId == null || agentId.isEmpty) return null;
      final firestore = ref.watch(firestoreProvider);
      final agentDoc = await firestore
          .collection(FirestoreCollections.agents)
          .doc(agentId)
          .get();
      if (!agentDoc.exists) return null;
      final userId = agentDoc.data()?['userId'] as String?;
      if (userId == null || userId.isEmpty) {
        return const AgentForVehicleView(agentId: '', fullName: 'Your agent');
      }
      final userDoc = await firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .get();
      final fullName = userDoc.data()?['fullName'] as String? ?? 'Your agent';
      final photoUrl = agentDoc.data()?['photoUrl'] as String?;
      return AgentForVehicleView(
        agentId: agentId,
        fullName: fullName,
        photoUrl: photoUrl,
      );
    });
