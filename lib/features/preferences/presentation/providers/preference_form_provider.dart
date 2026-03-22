import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/exchange_rate_model.dart';
import '../../../../shared/providers/exchange_rate_provider.dart';
import '../../../../shared/providers/firebase_providers.dart';
import '../../data/datasources/preferences_firestore_data_source.dart';
import '../../data/repositories/preferences_repository_impl.dart';
import '../../domain/entities/preference_submission.dart';
import '../../domain/repositories/preferences_repository.dart';
import '../../domain/usecases/create_order_from_preferences_use_case.dart';

enum PreferenceCondition {
  readyToDrive,
  needsModerateRepair,
  fullRebuildProject,
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

class PreferenceFormState {
  final int currentStep;
  final String make;
  final String model;
  final int yearFrom;
  final int yearTo;
  final PreferenceCondition condition;
  final MileageBand mileageBand;
  final bool repairOptedIn;
  final bool expandedDeposit;
  final bool expandedServiceFee;
  final bool expandedBalanceShipping;
  final bool expandedImportDuty;
  final bool expandedPortClearance;
  final bool expandedRepairs;

  const PreferenceFormState({
    this.currentStep = 1,
    this.make = 'Toyota',
    this.model = 'Camry',
    this.yearFrom = 2019,
    this.yearTo = 2019,
    this.condition = PreferenceCondition.readyToDrive,
    this.mileageBand = MileageBand.m70k,
    this.repairOptedIn = true,
    this.expandedDeposit = true,
    this.expandedServiceFee = false,
    this.expandedBalanceShipping = false,
    this.expandedImportDuty = false,
    this.expandedPortClearance = false,
    this.expandedRepairs = false,
  });

  bool get isSingleYear => yearFrom == yearTo;

  PreferenceFormState copyWith({
    int? currentStep,
    String? make,
    String? model,
    int? yearFrom,
    int? yearTo,
    PreferenceCondition? condition,
    MileageBand? mileageBand,
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
      make: make ?? this.make,
      model: model ?? this.model,
      yearFrom: yearFrom ?? this.yearFrom,
      yearTo: yearTo ?? this.yearTo,
      condition: condition ?? this.condition,
      mileageBand: mileageBand ?? this.mileageBand,
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

  void nextStep() {
    if (state.currentStep < 5) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 1) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void updateMake(String make, List<String> models) {
    state = state.copyWith(make: make, model: models.first);
  }

  void updateModel(String model) => state = state.copyWith(model: model);

  void updateYearFrom(int yearFrom) {
    final correctedTo = state.yearTo < yearFrom ? yearFrom : state.yearTo;
    state = state.copyWith(yearFrom: yearFrom, yearTo: correctedTo);
  }

  void updateYearTo(int yearTo) {
    final correctedTo = yearTo < state.yearFrom ? state.yearFrom : yearTo;
    state = state.copyWith(yearTo: correctedTo);
  }

  void updateCondition(PreferenceCondition value) =>
      state = state.copyWith(condition: value);
  void updateMileage(MileageBand value) => state = state.copyWith(mileageBand: value);
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
  final snapshot = await firestore.collection(FirestoreCollections.costDefaults).get();
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
  };
});

final liveCostEstimateProvider = Provider<AsyncValue<CostEstimate>>((ref) {
  final form = ref.watch(preferenceFormProvider);
  final exchange = ref.watch(exchangeRateProvider);
  final defaults = ref.watch(costDefaultsProvider);

  if (exchange is AsyncData<ExchangeRateModel> &&
      defaults is AsyncData<Map<String, double>>) {
    return _estimate(
      form: form,
      exchangeRate: exchange.value.usdToGhs,
      defaults: defaults.value,
    );
  }
  return const AsyncValue.loading();
});

AsyncValue<CostEstimate> _estimate({
  required PreferenceFormState form,
  required double exchangeRate,
  required Map<String, double> defaults,
}) {
  final base = defaults['baseEstimateReadyTodriveGhs'] ?? 117500;
  final conditionAdj = switch (form.condition) {
    PreferenceCondition.readyToDrive => 0.0,
    PreferenceCondition.needsModerateRepair => -15000.0,
    PreferenceCondition.fullRebuildProject => -30000.0,
  };
  final mileageAdj = switch (form.mileageBand) {
    MileageBand.m50k => 12000.0,
    MileageBand.m70k => 0.0,
    MileageBand.m100k => -10000.0,
    MileageBand.any => -18000.0,
  };
  final ghs = base + conditionAdj + mileageAdj;
  return AsyncValue.data(
    CostEstimate(
      ghs: ghs,
      usd: ghs / exchangeRate,
      exchangeRate: exchangeRate,
    ),
  );
}

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
  final condition = switch (state.condition) {
    PreferenceCondition.readyToDrive => FirestoreEnumValues.vehicleConditionRunAndDrive,
    PreferenceCondition.needsModerateRepair => FirestoreEnumValues.vehicleConditionRepairable,
    PreferenceCondition.fullRebuildProject => FirestoreEnumValues.vehicleConditionFullRebuild,
  };
  final label = switch (state.condition) {
    PreferenceCondition.readyToDrive => 'Ready to drive',
    PreferenceCondition.needsModerateRepair => 'Needs moderate repair',
    PreferenceCondition.fullRebuildProject => 'Full rebuild project',
  };
  final mileage = switch (state.mileageBand) {
    MileageBand.m50k => 50000,
    MileageBand.m70k => 70000,
    MileageBand.m100k => 100000,
    MileageBand.any => 200000,
  };
  return PreferenceSubmission(
    make: state.make,
    model: state.model,
    yearMin: state.yearFrom,
    yearMax: state.yearTo,
    condition: condition,
    conditionLabel: label,
    maxMileage: mileage,
    repairOptedIn: state.repairOptedIn,
  );
}

