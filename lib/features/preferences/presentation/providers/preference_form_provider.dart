import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/providers/exchange_rate_provider.dart';
import '../../../../shared/providers/firebase_providers.dart';
import '../../../../shared/providers/system_settings_provider.dart';
import '../../../catalogue/domain/entities/car_make.dart';
import '../../../catalogue/domain/entities/car_model.dart';
import '../../../catalogue/presentation/providers/car_catalogue_providers.dart';
import '../../core/preference_catalogue_utils.dart';
import '../../domain/budget_fit.dart';
import '../../domain/china_import_mode.dart';
import '../../data/datasources/preferences_firestore_data_source.dart';
import '../../data/repositories/preferences_repository_impl.dart';
import '../../domain/entities/preference_submission.dart';
import '../../domain/repositories/preferences_repository.dart';
import '../../domain/usecases/create_order_from_preferences_use_case.dart';

enum PreferenceCondition {
  readyToDrive,
  needsModerateRepair,
  newVehicle,
  goodCondition,
  fairCondition;

  static PreferenceCondition fromString(String s) => switch (s) {
        'run_and_drive' => PreferenceCondition.readyToDrive,
        'repairable' => PreferenceCondition.needsModerateRepair,
        'new_vehicle' => PreferenceCondition.newVehicle,
        'good_condition' => PreferenceCondition.goodCondition,
        'fair_condition' => PreferenceCondition.fairCondition,
        _ => PreferenceCondition.readyToDrive,
      };
}

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

class DepositBreakdown {
  final double estimatedLandedGhs;
  final double depositGhs;
  final double serviceFeeGhs;
  final double depositPercent;

  const DepositBreakdown({
    required this.estimatedLandedGhs,
    required this.depositGhs,
    required this.serviceFeeGhs,
    required this.depositPercent,
  });

  double get initialPaymentGhs => depositGhs + serviceFeeGhs;
}

const _undefined = Object();

String preferenceConditionToFirestoreString(PreferenceCondition c) =>
    switch (c) {
      PreferenceCondition.readyToDrive =>
        FirestoreEnumValues.vehicleConditionRunAndDrive,
      PreferenceCondition.needsModerateRepair =>
        FirestoreEnumValues.vehicleConditionRepairable,
      PreferenceCondition.newVehicle =>
        FirestoreEnumValues.vehicleConditionNewVehicle,
      PreferenceCondition.goodCondition =>
        FirestoreEnumValues.vehicleConditionGoodCondition,
      PreferenceCondition.fairCondition =>
        FirestoreEnumValues.vehicleConditionFairCondition,
    };

String preferenceConditionUiLabel(PreferenceCondition c) => switch (c) {
      PreferenceCondition.readyToDrive => 'Ready to use',
      PreferenceCondition.needsModerateRepair => 'Needs some work',
      PreferenceCondition.newVehicle => 'Brand new',
      PreferenceCondition.goodCondition => 'Good condition',
      PreferenceCondition.fairCondition => 'Fair condition',
    };

/// Rolling 4-year window ending at the most recent full model year.
(int, int) preferenceDefaultYearRange() {
  final yearTo = DateTime.now().year - 1;
  return (yearTo - 3, yearTo);
}

/// Agent-side search default when the buyer does not specify mileage.
const int preferenceDefaultMaxMileage = 100000;

class PreferenceFormState {
  /// 1 = your car, 2 = confirm
  final int currentStep;
  final ChinaImportMode chinaImportMode;
  final bool showAdvancedSourcing;
  final String advancedPurchaseOrigin;
  final bool yearRangeExpanded;
  final int? maxBudgetUsd;
  final String? trim;
  final String? makeSlug;
  final String? modelSlug;
  final String make;
  final String model;
  final int yearFrom;
  final int yearTo;
  final PreferenceCondition condition;
  final int maxMileage;

  const PreferenceFormState({
    this.currentStep = 1,
    this.chinaImportMode = ChinaImportMode.none,
    this.showAdvancedSourcing = false,
    this.advancedPurchaseOrigin = AppConstants.purchaseOriginAny,
    this.yearRangeExpanded = true,
    this.maxBudgetUsd,
    this.trim,
    this.makeSlug,
    this.modelSlug,
    this.make = '',
    this.model = '',
    this.yearFrom = 2022,
    this.yearTo = 2025,
    this.condition = PreferenceCondition.readyToDrive,
    this.maxMileage = preferenceDefaultMaxMileage,
  });

  factory PreferenceFormState.initial() {
    final (from, to) = preferenceDefaultYearRange();
    return PreferenceFormState(
      yearRangeExpanded: true,
      yearFrom: from,
      yearTo: to,
      maxMileage: preferenceDefaultMaxMileage,
    );
  }

  bool get isNewVehicle => chinaImportMode == ChinaImportMode.newFromChina;

  bool get isChinaUsed => chinaImportMode == ChinaImportMode.usedFromChina;

  bool get isUsedImport => chinaImportMode == ChinaImportMode.none;

  int get totalSteps => 2;

  int get displayStep => currentStep.clamp(1, 2);

  bool get isSingleYear => !yearRangeExpanded || yearFrom == yearTo;

  int get yearMin => yearFrom;

  int get yearMax => yearRangeExpanded ? yearTo : yearFrom;

  String get purchaseOrigin => resolvePurchaseOrigin(
        chinaImportMode: chinaImportMode,
        advancedPurchaseOrigin: advancedPurchaseOrigin,
      );

  String get progressLabel => switch (currentStep) {
        1 => 'Your car',
        2 => 'Confirm',
        _ => 'Your car',
      };

  bool get canProceedFromCar => make.isNotEmpty && model.isNotEmpty;

  PreferenceFormState copyWith({
    int? currentStep,
    ChinaImportMode? chinaImportMode,
    bool? showAdvancedSourcing,
    String? advancedPurchaseOrigin,
    bool? yearRangeExpanded,
    Object? maxBudgetUsd = _undefined,
    Object? trim = _undefined,
    Object? makeSlug = _undefined,
    Object? modelSlug = _undefined,
    String? make,
    String? model,
    int? yearFrom,
    int? yearTo,
    PreferenceCondition? condition,
    int? maxMileage,
  }) {
    return PreferenceFormState(
      currentStep: currentStep ?? this.currentStep,
      chinaImportMode: chinaImportMode ?? this.chinaImportMode,
      showAdvancedSourcing: showAdvancedSourcing ?? this.showAdvancedSourcing,
      advancedPurchaseOrigin:
          advancedPurchaseOrigin ?? this.advancedPurchaseOrigin,
      yearRangeExpanded: yearRangeExpanded ?? this.yearRangeExpanded,
      maxBudgetUsd: identical(maxBudgetUsd, _undefined)
          ? this.maxBudgetUsd
          : maxBudgetUsd as int?,
      trim: identical(trim, _undefined) ? this.trim : trim as String?,
      makeSlug:
          identical(makeSlug, _undefined) ? this.makeSlug : makeSlug as String?,
      modelSlug: identical(modelSlug, _undefined)
          ? this.modelSlug
          : modelSlug as String?,
      make: make ?? this.make,
      model: model ?? this.model,
      yearFrom: yearFrom ?? this.yearFrom,
      yearTo: yearTo ?? this.yearTo,
      condition: condition ?? this.condition,
      maxMileage: maxMileage ?? this.maxMileage,
    );
  }
}

class PreferenceFormNotifier extends StateNotifier<PreferenceFormState> {
  PreferenceFormNotifier() : super(PreferenceFormState.initial());

  void reset() => state = PreferenceFormState.initial();

  void toggleAdvancedSourcing() {
    state = state.copyWith(showAdvancedSourcing: !state.showAdvancedSourcing);
  }

  void updateAdvancedPurchaseOrigin(String origin) {
    state = state.copyWith(advancedPurchaseOrigin: origin);
  }

  void updateChinaImportMode(ChinaImportMode mode) {
    var next = state.copyWith(chinaImportMode: mode);
    if (mode == ChinaImportMode.newFromChina) {
      next = next.copyWith(
        condition: PreferenceCondition.newVehicle,
        maxMileage: 0,
        yearRangeExpanded: false,
      );
    } else if (mode == ChinaImportMode.usedFromChina) {
      next = next.copyWith(
        condition: PreferenceCondition.goodCondition,
        maxMileage: preferenceDefaultMaxMileage,
      );
    } else {
      final (from, to) = preferenceDefaultYearRange();
      next = next.copyWith(
        condition: PreferenceCondition.readyToDrive,
        maxMileage: preferenceDefaultMaxMileage,
        yearRangeExpanded: true,
        yearFrom: from,
        yearTo: to,
      );
    }
    state = _clearVehicleIfIncompatible(next);
  }

  PreferenceFormState _clearVehicleIfIncompatible(PreferenceFormState s) {
    // Caller may pass make slug without CarMake — clearing handled at pick time.
    return s;
  }

  void clearVehicleSelection() {
    state = state.copyWith(
      make: '',
      model: '',
      trim: null,
      makeSlug: null,
      modelSlug: null,
    );
  }

  void applyCatalogueMake(CarMake make, {required bool allowed}) {
    if (!allowed) {
      clearVehicleSelection();
      return;
    }
    state = state.copyWith(
      make: make.name,
      makeSlug: make.slug,
      model: '',
      modelSlug: null,
      trim: null,
    );
  }

  void applyCatalogueModel(CarModel model) {
    state = state.copyWith(
      model: model.name,
      modelSlug: model.slug,
      trim: null,
    );
  }

  void applyQuickPick(CarMake make, CarModel model) {
    state = state.copyWith(
      make: make.name,
      makeSlug: make.slug,
      model: model.name,
      modelSlug: model.slug,
      trim: null,
    );
  }

  void updateTrim(String? trim) => state = state.copyWith(trim: trim);

  void commitMaxBudgetUsd(int? usd) =>
      state = state.copyWith(maxBudgetUsd: usd);

  void setYearRangeExpanded(bool expanded) {
    if (!expanded) {
      state = state.copyWith(
        yearRangeExpanded: false,
        yearTo: state.yearFrom,
      );
    } else {
      state = state.copyWith(yearRangeExpanded: true);
    }
  }

  void updateYearFrom(int year) {
    final to = state.yearRangeExpanded
        ? (state.yearTo < year ? year : state.yearTo)
        : year;
    state = state.copyWith(yearFrom: year, yearTo: to);
  }

  void updateYearTo(int year) {
    final to = year < state.yearFrom ? state.yearFrom : year;
    state = state.copyWith(yearTo: to);
  }

  void updateCondition(PreferenceCondition value) {
    state = state.copyWith(condition: value);
  }

  void updateMaxMileage(int miles) {
    state = state.copyWith(maxMileage: miles);
  }

  void nextStep() {
    if (state.currentStep == 1) {
      state = state.copyWith(currentStep: 2);
    }
  }

  void previousStep() {
    if (state.currentStep > 1) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void goToStep(int step) {
    if (step >= 1 && step <= 2) {
      state = state.copyWith(currentStep: step);
    }
  }
}

final preferenceFormProvider =
    StateNotifierProvider<PreferenceFormNotifier, PreferenceFormState>(
  (ref) => PreferenceFormNotifier(),
);

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
    'serviceFeeGhs': 1500,
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
    baseAuctionUsd =
        modelPrice ?? defaults['averageAuctionPriceUsd'] ?? 8000.0;
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

/// Qualitative budget fit for review — never exposes estimate figures to UI.
final budgetFitAssessmentProvider =
    Provider<AsyncValue<BudgetFitAssessment?>>((ref) {
  final state = ref.watch(preferenceFormProvider);
  final budget = state.maxBudgetUsd;
  if (budget == null || state.isNewVehicle) {
    return const AsyncValue.data(null);
  }

  return ref.watch(liveCostEstimateProvider).when(
        data: (estimate) {
          if (estimate == null) return const AsyncValue.data(null);
          final assessment = resolveBudgetFit(
            budgetUsd: budget,
            estimateLandedUsd: estimate.usd,
            isYearRange: !state.isSingleYear,
          );
          return AsyncValue.data(assessment);
        },
        loading: () => const AsyncValue.loading(),
        error: (e, st) => AsyncValue.error(e, st),
      );
});

final preferenceDepositBreakdownProvider =
    FutureProvider.autoDispose<DepositBreakdown?>((ref) async {
  final state = ref.watch(preferenceFormProvider);
  if (state.isNewVehicle) return null;

  final estimate = await ref.watch(_liveCostEstimateFutureProvider.future);
  if (estimate == null) return null;

  final defaults = await ref.watch(costDefaultsProvider.future);
  final settings = await ref.watch(systemSettingsProvider.future);

  final depositPct = settings.numValue('depositPercentage', fallback: 0.10);
  final serviceFee = defaults['serviceFeeGhs'] ??
      settings.numValue('serviceFeeGhs', fallback: 1500);

  return DepositBreakdown(
    estimatedLandedGhs: estimate.ghs,
    depositGhs: estimate.ghs * depositPct,
    serviceFeeGhs: serviceFee,
    depositPercent: depositPct,
  );
});

/// Popular make + first model pairs for one-tap quick picks.
final popularQuickPicksProvider =
    FutureProvider.autoDispose<List<({CarMake make, CarModel model})>>(
        (ref) async {
  final state = ref.watch(preferenceFormProvider);
  final popular = ref.watch(popularMakesProvider);
  final picks = <({CarMake make, CarModel model})>[];

  for (final make in popular.take(6)) {
    if (!isMakeAllowedForImportMode(make, state.chinaImportMode)) continue;
    try {
      final models = await ref.read(carModelsProvider(make.slug).future);
      if (models.isEmpty) continue;
      picks.add((make: make, model: models.first));
    } catch (_) {
      continue;
    }
  }
  return picks;
});

final preferencesDataSourceProvider =
    Provider<PreferencesFirestoreDataSource>((ref) {
  return PreferencesFirestoreDataSource(ref.watch(firestoreProvider));
});

final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  return PreferencesRepositoryImpl(ref.watch(preferencesDataSourceProvider));
});

final createOrderFromPreferencesUseCaseProvider =
    Provider<CreateOrderFromPreferencesUseCase>((ref) {
  return CreateOrderFromPreferencesUseCase(
    ref.watch(preferencesRepositoryProvider),
  );
});

PreferenceSubmission toSubmission(
  PreferenceFormState state, {
  required double exchangeRateUsdToGhs,
}) {
  final condition = preferenceConditionToFirestoreString(state.condition);
  final label = preferenceConditionUiLabel(state.condition);
  final budgetUsd = state.maxBudgetUsd;
  int? budgetGhs;
  if (budgetUsd != null && exchangeRateUsdToGhs > 0) {
    budgetGhs = (budgetUsd * exchangeRateUsdToGhs).round();
  }
  return PreferenceSubmission(
    make: state.make,
    model: state.model,
    yearMin: state.yearMin,
    yearMax: state.yearMax,
    condition: condition,
    conditionLabel: label,
    maxMileage: state.isNewVehicle ? 0 : state.maxMileage,
    trim: state.trim,
    purchaseOrigin: state.purchaseOrigin,
    isNewVehicle: state.isNewVehicle,
    maxBudgetUsd: budgetUsd,
    maxBudgetGhs: budgetGhs,
  );
}
