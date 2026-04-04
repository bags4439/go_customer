import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/providers/exchange_rate_provider.dart';
import '../../../../shared/providers/firebase_providers.dart';
import '../../../catalogue/domain/entities/car_model.dart';
import '../../../catalogue/presentation/providers/car_catalogue_providers.dart';
import '../../data/datasources/preferences_firestore_data_source.dart';
import '../../data/repositories/preferences_repository_impl.dart';
import '../../domain/entities/preference_submission.dart';
import '../../domain/repositories/preferences_repository.dart';
import '../../domain/usecases/create_order_from_preferences_use_case.dart';

enum PreferenceCondition {
  readyToDrive,
  needsModerateRepair,
  fullRebuildProject,
  newVehicle,
  goodCondition,
  fairCondition;

  static PreferenceCondition fromString(String s) => switch (s) {
        'run_and_drive' => PreferenceCondition.readyToDrive,
        'repairable' => PreferenceCondition.needsModerateRepair,
        'full_rebuild' => PreferenceCondition.fullRebuildProject,
        'new_vehicle' => PreferenceCondition.newVehicle,
        'good_condition' => PreferenceCondition.goodCondition,
        'fair_condition' => PreferenceCondition.fairCondition,
        _ => PreferenceCondition.readyToDrive,
      };
}

enum MileageBand { m50k, m70k, m100k, any }

class CostEstimate {
  final double ghs;
  final double usd;
  final double exchangeRate;

  const CostEstimate({
    required this.ghs,
    required this.usd,
    required this.exchangeRate,
  });
}

const _undefined = Object();

String preferenceConditionToFirestoreString(PreferenceCondition c) =>
    switch (c) {
      PreferenceCondition.readyToDrive =>
        FirestoreEnumValues.vehicleConditionRunAndDrive,
      PreferenceCondition.needsModerateRepair =>
        FirestoreEnumValues.vehicleConditionRepairable,
      PreferenceCondition.fullRebuildProject =>
        FirestoreEnumValues.vehicleConditionFullRebuild,
      PreferenceCondition.newVehicle =>
        FirestoreEnumValues.vehicleConditionNewVehicle,
      PreferenceCondition.goodCondition =>
        FirestoreEnumValues.vehicleConditionGoodCondition,
      PreferenceCondition.fairCondition =>
        FirestoreEnumValues.vehicleConditionFairCondition,
    };

String preferenceConditionUiLabel(PreferenceCondition c) => switch (c) {
      PreferenceCondition.readyToDrive => 'Ready to drive',
      PreferenceCondition.needsModerateRepair => 'Needs moderate repair',
      PreferenceCondition.fullRebuildProject => 'Full rebuild project',
      PreferenceCondition.newVehicle => 'Brand new',
      PreferenceCondition.goodCondition => 'Good condition',
      PreferenceCondition.fairCondition => 'Fair condition',
    };

class PreferenceFormState {
  final int currentStep;
  final String purchaseOrigin;
  final String? trim;
  final String? makeSlug;
  final String? modelSlug;
  final bool isNewVehicle;
  final bool skipConditionStep;
  final String make;
  final String model;
  final int yearFrom;
  final int yearTo;
  final PreferenceCondition condition;
  final MileageBand mileageBand;
  final int maxMileage;
  final bool repairOptedIn;
  final bool expandedDeposit;
  final bool expandedServiceFee;
  final bool expandedBalanceShipping;
  final bool expandedImportDuty;
  final bool expandedPortClearance;
  final bool expandedRepairs;

  const PreferenceFormState({
    this.currentStep = 1,
    this.purchaseOrigin = AppConstants.purchaseOriginAny,
    this.trim,
    this.makeSlug,
    this.modelSlug,
    this.isNewVehicle = false,
    this.skipConditionStep = false,
    this.make = '',
    this.model = '',
    this.yearFrom = 2019,
    this.yearTo = 2019,
    this.condition = PreferenceCondition.readyToDrive,
    this.mileageBand = MileageBand.m70k,
    this.maxMileage = 70000,
    this.repairOptedIn = true,
    this.expandedDeposit = true,
    this.expandedServiceFee = false,
    this.expandedBalanceShipping = false,
    this.expandedImportDuty = false,
    this.expandedPortClearance = false,
    this.expandedRepairs = false,
  });

  bool get isSingleYear => yearFrom == yearTo;

  int get yearMin => yearFrom;

  int get yearMax => yearTo;

  bool get isChina => purchaseOrigin == AppConstants.purchaseOriginChina;

  bool get isUsOrDubai =>
      purchaseOrigin == AppConstants.purchaseOriginUsCanada ||
      purchaseOrigin == AppConstants.purchaseOriginDubai ||
      purchaseOrigin == AppConstants.purchaseOriginAny;

  bool get showConditionStep => !skipConditionStep;

  bool get showMileageField => !isNewVehicle;

  bool get showRepairField => !isNewVehicle;

  PreferenceFormState copyWith({
    int? currentStep,
    String? purchaseOrigin,
    Object? trim = _undefined,
    Object? makeSlug = _undefined,
    Object? modelSlug = _undefined,
    bool? isNewVehicle,
    bool? skipConditionStep,
    String? make,
    String? model,
    int? yearFrom,
    int? yearTo,
    PreferenceCondition? condition,
    MileageBand? mileageBand,
    int? maxMileage,
    bool? repairOptedIn,
    bool? expandedDeposit,
    bool? expandedServiceFee,
    bool? expandedBalanceShipping,
    bool? expandedImportDuty,
    bool? expandedPortClearance,
    bool? expandedRepairs,
  }) {
    return PreferenceFormState(
      currentStep: currentStep ?? this.currentStep,
      purchaseOrigin: purchaseOrigin ?? this.purchaseOrigin,
      trim: identical(trim, _undefined) ? this.trim : trim as String?,
      makeSlug: identical(makeSlug, _undefined) ? this.makeSlug : makeSlug as String?,
      modelSlug:
          identical(modelSlug, _undefined) ? this.modelSlug : modelSlug as String?,
      isNewVehicle: isNewVehicle ?? this.isNewVehicle,
      skipConditionStep: skipConditionStep ?? this.skipConditionStep,
      make: make ?? this.make,
      model: model ?? this.model,
      yearFrom: yearFrom ?? this.yearFrom,
      yearTo: yearTo ?? this.yearTo,
      condition: condition ?? this.condition,
      mileageBand: mileageBand ?? this.mileageBand,
      maxMileage: maxMileage ?? this.maxMileage,
      repairOptedIn: repairOptedIn ?? this.repairOptedIn,
      expandedDeposit: expandedDeposit ?? this.expandedDeposit,
      expandedServiceFee: expandedServiceFee ?? this.expandedServiceFee,
      expandedBalanceShipping:
          expandedBalanceShipping ?? this.expandedBalanceShipping,
      expandedImportDuty: expandedImportDuty ?? this.expandedImportDuty,
      expandedPortClearance: expandedPortClearance ?? this.expandedPortClearance,
      expandedRepairs: expandedRepairs ?? this.expandedRepairs,
    );
  }
}

class PreferenceFormNotifier extends StateNotifier<PreferenceFormState> {
  PreferenceFormNotifier() : super(const PreferenceFormState());

  /// Clears draft state when opening a fresh "new preferences" flow
  /// (e.g. import another car).
  void reset() => state = const PreferenceFormState();

  void updatePurchaseOrigin(String origin) {
    final isChina = origin == AppConstants.purchaseOriginChina;
    String? newCondition;
    int? newMileage;

    if (origin == AppConstants.purchaseOriginUsCanada ||
        origin == AppConstants.purchaseOriginAny) {
      newCondition = FirestoreEnumValues.vehicleConditionRunAndDrive;
      newMileage = 100000;
    } else if (origin == AppConstants.purchaseOriginDubai) {
      newCondition = FirestoreEnumValues.vehicleConditionRunAndDrive;
      newMileage = 70000;
    } else if (isChina) {
      newCondition = FirestoreEnumValues.vehicleConditionNewVehicle;
      newMileage = 0;
    }

    state = state.copyWith(
      purchaseOrigin: origin,
      isNewVehicle: isChina,
      skipConditionStep: isChina,
      condition: newCondition != null
          ? PreferenceCondition.fromString(newCondition)
          : state.condition,
      maxMileage: newMileage ?? state.maxMileage,
    );
  }

  void updateTrim(String? trim) {
    state = state.copyWith(trim: trim);
  }

  void clearTrim() {
    state = state.copyWith(trim: null);
  }

  void updateMakeSlug(String slug) {
    state = state.copyWith(makeSlug: slug, modelSlug: null);
  }

  void updateModelSlug(String slug) {
    state = state.copyWith(modelSlug: slug);
  }

  void nextStep() {
    final next = state.currentStep + 1;
    if (next == 3 && state.skipConditionStep) {
      state = state.copyWith(currentStep: 4);
      return;
    }
    if (next <= 4) {
      state = state.copyWith(currentStep: next);
    }
  }

  void previousStep() {
    final prev = state.currentStep - 1;
    if (prev == 3 && state.skipConditionStep) {
      state = state.copyWith(currentStep: 2);
      return;
    }
    if (prev >= 1) {
      state = state.copyWith(currentStep: prev);
    }
  }

  void goToStep(int step) {
    if (step >= 1 && step <= 4) {
      state = state.copyWith(currentStep: step);
    }
  }

  void updateMake(String make, List<String> models) {
    state = state.copyWith(
      make: make,
      model: models.isNotEmpty ? models.first : '',
      trim: null,
      modelSlug: null,
    );
  }

  void updateModel(String model) {
    state = state.copyWith(
      model: model,
      trim: null,
      modelSlug: null,
    );
  }

  void updateYearFrom(int yearFrom) {
    final correctedTo = state.yearTo < yearFrom ? yearFrom : state.yearTo;
    state = state.copyWith(yearFrom: yearFrom, yearTo: correctedTo);
  }

  void updateYearTo(int yearTo) {
    final correctedTo = yearTo < state.yearFrom ? state.yearFrom : yearTo;
    state = state.copyWith(yearTo: correctedTo);
  }

  void updateCondition(PreferenceCondition value) {
    final china = state.purchaseOrigin == AppConstants.purchaseOriginChina;
    final isNew = china && value == PreferenceCondition.newVehicle;
    state = state.copyWith(
      condition: value,
      isNewVehicle: isNew,
      skipConditionStep: isNew,
    );
  }

  void updateMileage(MileageBand value) {
    final miles = switch (value) {
      MileageBand.m50k => 50000,
      MileageBand.m70k => 70000,
      MileageBand.m100k => 100000,
      MileageBand.any => 200000,
    };
    state = state.copyWith(mileageBand: value, maxMileage: miles);
  }

  void updateMaxMileage(int miles) {
    final band = miles <= 50000
        ? MileageBand.m50k
        : miles <= 70000
            ? MileageBand.m70k
            : miles <= 100000
                ? MileageBand.m100k
                : MileageBand.any;
    state = state.copyWith(maxMileage: miles, mileageBand: band);
  }

  void updateRepairOptedIn(bool value) => state = state.copyWith(repairOptedIn: value);

  void toggleExpanded(String key) {
    switch (key) {
      case 'deposit':
        state = state.copyWith(expandedDeposit: !state.expandedDeposit);
      case 'service':
        state = state.copyWith(expandedServiceFee: !state.expandedServiceFee);
      case 'balance':
        state = state.copyWith(
            expandedBalanceShipping: !state.expandedBalanceShipping);
      case 'duty':
        state = state.copyWith(expandedImportDuty: !state.expandedImportDuty);
      case 'clearance':
        state = state.copyWith(
            expandedPortClearance: !state.expandedPortClearance);
      case 'repairs':
        state = state.copyWith(expandedRepairs: !state.expandedRepairs);
    }
  }
}

final preferenceFormProvider =
    StateNotifierProvider<PreferenceFormNotifier, PreferenceFormState>(
  (ref) => PreferenceFormNotifier(),
);

final makeOptionsProvider = Provider<List<String>>((ref) => const [
      'Toyota',
      'Honda',
      'Nissan',
      'Hyundai',
      'Kia',
      'Ford',
      'Chevrolet',
      'Other',
    ]);

final modelOptionsProvider = Provider<Map<String, List<String>>>((ref) => const {
      'Toyota': ['Camry', 'Corolla', 'RAV4', 'Highlander'],
      'Honda': ['Accord', 'Civic', 'CR-V', 'Pilot'],
      'Nissan': ['Altima', 'Sentra', 'Rogue', 'Pathfinder'],
      'Hyundai': ['Elantra', 'Sonata', 'Tucson', 'Santa Fe'],
      'Kia': ['K5', 'Rio', 'Sportage', 'Sorento'],
      'Ford': ['Fusion', 'Escape', 'Edge', 'Explorer'],
      'Chevrolet': ['Malibu', 'Cruze', 'Equinox', 'Traverse'],
      'Other': ['Other'],
    });

final costDefaultsProvider = FutureProvider<Map<String, double>>((ref) async {
  final firestore = ref.watch(firestoreProvider);
  final snapshot =
      await firestore.collection(FirestoreCollections.costDefaults).get();
  if (snapshot.docs.isNotEmpty) {
    final map = <String, double>{};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final key = (data['key'] ?? doc.id).toString();
      final value = data['value'];
      if (value is num) {
        map[key] = value.toDouble();
      }
    }
    if (map.isNotEmpty) return map;
  }
  return {
    'baseEstimateReadyTodriveGhs': 117500,
    'serviceFeeGhs': 1500,
    'clearanceServiceFeeGhs': 3200,
    'repairPlatformFeeGhs': 2800,
    'averageAuctionPriceUsd': 8000,
    'averageShippingUsd': 1800,
    'importDutyRate': 0.35,
    'exchangeRateGhsPerUsd': 15.5,
  };
});

final _liveCostEstimateFutureProvider =
    FutureProvider.autoDispose<CostEstimate?>((ref) async {
  final state = ref.watch(preferenceFormProvider);

  if (state.isNewVehicle) return null;

  final defaults = await ref.watch(costDefaultsProvider.future);
  final exchangeModel = await ref.watch(exchangeRateProvider.future);

  double exchangeRate = exchangeModel.usdToGhs;
  final rateFromDefaults = defaults['exchangeRateGhsPerUsd'];
  if (rateFromDefaults != null && rateFromDefaults > 0) {
    exchangeRate = rateFromDefaults;
  }

  final makeSlug = state.makeSlug;
  final modelSlug = state.modelSlug;

  double baseAuctionUsd;
  if (makeSlug != null &&
      modelSlug != null &&
      makeSlug.isNotEmpty &&
      modelSlug.isNotEmpty) {
    List<CarModel> models = [];
    try {
      models = await ref.watch(carModelsProvider(makeSlug).future);
    } catch (_) {
      models = [];
    }
    CarModel? matched;
    for (final m in models) {
      if (m.slug == modelSlug) {
        matched = m;
        break;
      }
    }
    final modelPrice = matched?.estimatedAuctionPriceForYears(
      state.yearMin,
      state.yearMax,
    );
    baseAuctionUsd = modelPrice ??
        defaults['averageAuctionPriceUsd'] ??
        8000.0;
  } else {
    baseAuctionUsd = defaults['averageAuctionPriceUsd'] ?? 8000.0;
  }

  final conditionKey =
      'auctionConditionMultiplier_${preferenceConditionToFirestoreString(state.condition)}';
  final multiplier = defaults[conditionKey] ?? 1.0;
  final adjustedAuctionUsd = baseAuctionUsd * multiplier;

  final shippingUsd = defaults['averageShippingUsd'] ?? 1800.0;
  final dutyRate = defaults['importDutyRate'] ?? 0.35;

  final totalUsd = adjustedAuctionUsd + shippingUsd;
  final dutyGhs = totalUsd * exchangeRate * dutyRate;
  final totalGhs = (totalUsd * exchangeRate) + dutyGhs;

  return CostEstimate(
    usd: totalUsd,
    ghs: totalGhs,
    exchangeRate: exchangeRate,
  );
});

final liveCostEstimateProvider = Provider<AsyncValue<CostEstimate?>>((ref) {
  return ref.watch(_liveCostEstimateFutureProvider);
});

final preferencesDataSourceProvider = Provider<PreferencesFirestoreDataSource>((ref) {
  return PreferencesFirestoreDataSource(ref.watch(firestoreProvider));
});

final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  return PreferencesRepositoryImpl(
    ref.watch(preferencesDataSourceProvider),
    ref.watch(functionsProvider),
  );
});

final createOrderFromPreferencesUseCaseProvider =
    Provider<CreateOrderFromPreferencesUseCase>((ref) {
  return CreateOrderFromPreferencesUseCase(ref.watch(preferencesRepositoryProvider));
});

PreferenceSubmission toSubmission(PreferenceFormState state) {
  final condition = preferenceConditionToFirestoreString(state.condition);
  final label = preferenceConditionUiLabel(state.condition);
  return PreferenceSubmission(
    make: state.make,
    model: state.model,
    yearMin: state.yearMin,
    yearMax: state.yearMax,
    condition: condition,
    conditionLabel: label,
    maxMileage: state.isNewVehicle ? 0 : state.maxMileage,
    repairOptedIn: state.isNewVehicle ? false : state.repairOptedIn,
    trim: state.trim,
    purchaseOrigin: state.purchaseOrigin,
    isNewVehicle: state.isNewVehicle,
  );
}
