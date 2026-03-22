import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/providers/exchange_rate_provider.dart';
import '../../../../shared/providers/firebase_providers.dart';
import '../../core/constants/vehicle_detail_constants.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/vehicle_firestore_data_source.dart';
import '../../data/repositories/vehicle_repository_impl.dart';
import '../../domain/entities/max_bid_entity.dart';
import '../../domain/entities/vehicle_option_entity.dart';
import '../../domain/repositories/vehicle_repository.dart';

final vehicleFirestoreDataSourceProvider = Provider<VehicleFirestoreDataSource>((ref) {
  return VehicleFirestoreDataSource(ref.watch(firestoreProvider));
});

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepositoryImpl(
    ref.watch(vehicleFirestoreDataSourceProvider),
    ref.watch(functionsProvider),
  );
});

final vehicleOptionProvider =
    FutureProvider.family<VehicleOptionEntity?, String>((ref, vehicleOptionId) async {
  return ref.watch(vehicleRepositoryProvider).getVehicleOption(vehicleOptionId);
});

final existingMaxBidProvider =
    FutureProvider.family<MaxBidEntity?, String>((ref, vehicleOptionId) async {
  final userId = ref.watch(authStateProvider).valueOrNull;
  if (userId == null) return null;
  return ref.watch(vehicleRepositoryProvider).getExistingMaxBid(
        vehicleOptionId: vehicleOptionId,
        buyerId: userId,
      );
});

enum BidImpactLevel { none, low, good, strong }

class MaxBidInputState {
  final String rawInput;
  final double? parsedUsd;
  final bool isValid;
  final BidImpactLevel impactLevel;

  const MaxBidInputState({
    this.rawInput = '',
    this.parsedUsd,
    this.isValid = false,
    this.impactLevel = BidImpactLevel.none,
  });
}

class MaxBidInputNotifier extends StateNotifier<MaxBidInputState> {
  MaxBidInputNotifier(this._vehicleOptionId, this._ref, double? initialUsd)
      : super(MaxBidInputState(
          rawInput: initialUsd != null && initialUsd > 0
              ? initialUsd.toStringAsFixed(0)
              : '4200',
          parsedUsd: initialUsd ?? 4200.0,
          isValid: true,
          impactLevel: BidImpactLevel.none,
        ));

  final String _vehicleOptionId;
  final Ref _ref;

  void setRawInput(String value) {
    final parsed = double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
    final usd = parsed != null && parsed > 0 ? parsed : null;
    final impact = _impactLevel(usd);
    state = MaxBidInputState(
      rawInput: value,
      parsedUsd: usd,
      isValid: usd != null && usd > 0,
      impactLevel: impact,
    );
  }

  void setPreset(double usd) {
    state = MaxBidInputState(
      rawInput: usd.toStringAsFixed(0),
      parsedUsd: usd,
      isValid: true,
      impactLevel: _impactLevel(usd),
    );
  }

  BidImpactLevel _impactLevel(double? bidUsd) {
    final option = _ref.read(vehicleOptionProvider(_vehicleOptionId)).valueOrNull;
    final auctionPrice = option?.auctionPriceUsd;
    if (auctionPrice == null || bidUsd == null || bidUsd <= 0) return BidImpactLevel.none;
    if (bidUsd < auctionPrice * 0.9) return BidImpactLevel.low;
    if (bidUsd <= auctionPrice * 1.2) return BidImpactLevel.good;
    return BidImpactLevel.strong;
  }
}

final maxBidInputNotifierProvider =
    StateNotifierProvider.family<MaxBidInputNotifier, MaxBidInputState, String>(
  (ref, vehicleOptionId) {
    final existing = ref.watch(existingMaxBidProvider(vehicleOptionId)).valueOrNull;
    return MaxBidInputNotifier(vehicleOptionId, ref, existing?.maxBidUsd);
  },
);

class CostLineItem {
  final String label;
  final String? usdText;
  final String? ghsText;
  final bool isDeduction;
  final bool isTotal;

  const CostLineItem({
    required this.label,
    this.usdText,
    this.ghsText,
    this.isDeduction = false,
    this.isTotal = false,
  });
}

class LiveCost {
  final double totalUsd;
  final double totalGhs;
  final String ghsConversionText;
  final List<CostLineItem> allLineItems;

  const LiveCost({
    required this.totalUsd,
    required this.totalGhs,
    required this.ghsConversionText,
    required this.allLineItems,
  });
}

final liveCostProvider = Provider.family<LiveCost?, String>((ref, vehicleOptionId) {
  final option = ref.watch(vehicleOptionProvider(vehicleOptionId)).valueOrNull;
  final rateAsync = ref.watch(exchangeRateProvider);
  final inputState = ref.watch(maxBidInputNotifierProvider(vehicleOptionId));
  final rate = rateAsync.valueOrNull?.usdToGhs;
  if (option == null) return null;
  final useBidUsd = inputState.parsedUsd ?? option.auctionPriceUsd ?? 0.0;
  final premiumPct = (option.buyersPremiumPct ?? 0) / 100;
  final premiumUsd = useBidUsd * premiumPct;
  final towing = option.towingStorageUsd ?? 0;
  final shipping = option.shippingUsd ?? 0;
  final marine = option.marineInsuranceUsd ?? 0;
  final depositUsd = (useBidUsd + premiumUsd) * 0.10;
  final dutyGhs = option.dutyGhs ?? 0;
  final repairGhs = option.repairEstimateGhs ?? 0;
  final serviceGhs = option.serviceFeeGhs ?? 0;
  final totalUsd = useBidUsd + premiumUsd + towing + shipping + marine;
  final r = (rate ?? 0.0).toDouble();
  final depositGhs = r > 0 ? depositUsd * r : 0;
  final totalGhs = (totalUsd * r) + dutyGhs + repairGhs + serviceGhs;
  final lineItems = <CostLineItem>[
    CostLineItem(
      label: VehicleDetailConstants.auctionPriceEst,
      usdText: CurrencyFormatter.formatUsd(useBidUsd),
      ghsText: r > 0 ? CurrencyFormatter.formatGhs(useBidUsd * r) : null,
    ),
    CostLineItem(
      label: '${VehicleDetailConstants.buyersPremium} (${(premiumPct * 100).toStringAsFixed(0)}%)',
      usdText: CurrencyFormatter.formatUsd(premiumUsd),
      ghsText: r > 0 ? CurrencyFormatter.formatGhs(premiumUsd * r) : null,
    ),
    CostLineItem(
      label: VehicleDetailConstants.usTowingStorage,
      usdText: CurrencyFormatter.formatUsd(towing),
      ghsText: r > 0 ? CurrencyFormatter.formatGhs(towing * r) : null,
    ),
    CostLineItem(
      label: VehicleDetailConstants.lessDepositPaid,
      usdText: '−${CurrencyFormatter.formatUsd(depositUsd.toDouble())}',
      ghsText: '−${CurrencyFormatter.formatGhs(depositGhs.toDouble())}',
      isDeduction: true,
    ),
    CostLineItem(
      label: VehicleDetailConstants.oceanFreight,
      usdText: CurrencyFormatter.formatUsd(shipping),
      ghsText: r > 0 ? CurrencyFormatter.formatGhs(shipping * r) : null,
    ),
    CostLineItem(
      label: VehicleDetailConstants.marineInsurance,
      usdText: CurrencyFormatter.formatUsd(marine),
      ghsText: r > 0 ? CurrencyFormatter.formatGhs(marine * r) : null,
    ),
    CostLineItem(
      label: VehicleDetailConstants.importDuty,
      usdText: '—',
      ghsText: CurrencyFormatter.formatGhs(dutyGhs),
    ),
  ];
  if (repairGhs > 0) {
    lineItems.add(CostLineItem(
      label: VehicleDetailConstants.repairsEst,
      usdText: '—',
      ghsText: CurrencyFormatter.formatGhs(repairGhs),
    ));
  }
  lineItems.add(CostLineItem(
    label: VehicleDetailConstants.totalLandedCost,
    usdText: CurrencyFormatter.formatUsd(totalUsd),
    ghsText: CurrencyFormatter.formatGhs(totalGhs),
    isTotal: true,
  ));
  final ghsConversionText = inputState.parsedUsd != null && inputState.parsedUsd! > 0 && r > 0
      ? '= ${CurrencyFormatter.formatGhs(inputState.parsedUsd! * r)} at today\'s rate'
      : '';
  return LiveCost(
    totalUsd: totalUsd,
    totalGhs: totalGhs,
    ghsConversionText: ghsConversionText,
    allLineItems: lineItems,
  );
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
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }
}

final agentForVehicleProvider =
    FutureProvider.family<AgentForVehicleView?, String>((ref, vehicleOptionId) async {
  final option = await ref.watch(vehicleOptionProvider(vehicleOptionId).future);
  final agentId = option?.agentId;
  if (agentId == null || agentId.isEmpty) return null;
  final firestore = ref.watch(firestoreProvider);
  final agentDoc = await firestore.collection(FirestoreCollections.agents).doc(agentId).get();
  if (!agentDoc.exists) return null;
  final userId = agentDoc.data()?['userId'] as String?;
  if (userId == null || userId.isEmpty) {
    return const AgentForVehicleView(agentId: '', fullName: 'Your agent');
  }
  final userDoc = await firestore.collection(FirestoreCollections.users).doc(userId).get();
  final fullName = userDoc.data()?['fullName'] as String? ?? 'Your agent';
  return AgentForVehicleView(agentId: agentId, fullName: fullName);
});
