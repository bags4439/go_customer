import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/repositories/preferences_repository.dart';
import '../../data/repositories/preferences_repository_impl.dart';
import '../../../../shared/providers/firebase_providers.dart';
import 'preference_form_provider.dart';

/// Snapshot of form values for comparison (originalValues).
class EditFormValues {
  final String make;
  final String model;
  final int yearMin;
  final int yearMax;
  final String condition;
  final String conditionLabel;
  final int maxMileage;
  final bool repairOptedIn;

  const EditFormValues({
    required this.make,
    required this.model,
    required this.yearMin,
    required this.yearMax,
    required this.condition,
    required this.conditionLabel,
    required this.maxMileage,
    required this.repairOptedIn,
  });
}

class EditFormState {
  final String? preferenceId;
  final String make;
  final String model;
  final int yearMin;
  final int yearMax;
  final PreferenceCondition condition;
  final int maxMileage;
  final bool repairOptedIn;
  final EditFormValues? originalValues;
  final bool isSaving;
  final String? error;

  const EditFormState({
    this.preferenceId,
    this.make = 'Toyota',
    this.model = 'Camry',
    this.yearMin = 2019,
    this.yearMax = 2019,
    this.condition = PreferenceCondition.readyToDrive,
    this.maxMileage = 70000,
    this.repairOptedIn = true,
    this.originalValues,
    this.isSaving = false,
    this.error,
  });

  bool get isSingleYear => yearMin == yearMax;
}

EditFormValues _formValuesFromState({
  required String make,
  required String model,
  required int yearMin,
  required int yearMax,
  required String condition,
  required String conditionLabel,
  required int maxMileage,
  required bool repairOptedIn,
}) =>
    EditFormValues(
      make: make,
      model: model,
      yearMin: yearMin,
      yearMax: yearMax,
      condition: condition,
      conditionLabel: conditionLabel,
      maxMileage: maxMileage,
      repairOptedIn: repairOptedIn,
    );

String _conditionToFirestore(PreferenceCondition c) {
  switch (c) {
    case PreferenceCondition.readyToDrive:
      return FirestoreEnumValues.vehicleConditionRunAndDrive;
    case PreferenceCondition.needsModerateRepair:
      return FirestoreEnumValues.vehicleConditionRepairable;
    case PreferenceCondition.fullRebuildProject:
      return FirestoreEnumValues.vehicleConditionFullRebuild;
  }
}

String _conditionLabel(PreferenceCondition c) {
  switch (c) {
    case PreferenceCondition.readyToDrive:
      return 'Ready to drive';
    case PreferenceCondition.needsModerateRepair:
      return 'Needs moderate repair';
    case PreferenceCondition.fullRebuildProject:
      return 'Full rebuild project';
  }
}

PreferenceCondition _conditionFromFirestore(String v) {
  switch (v) {
    case FirestoreEnumValues.vehicleConditionRepairable:
      return PreferenceCondition.needsModerateRepair;
    case FirestoreEnumValues.vehicleConditionFullRebuild:
      return PreferenceCondition.fullRebuildProject;
    default:
      return PreferenceCondition.readyToDrive;
  }
}

final orderEditPreferencesRepositoryProvider =
    Provider<PreferencesRepository>((ref) {
  return PreferencesRepositoryImpl(
    ref.watch(preferencesDataSourceProvider),
    ref.watch(functionsProvider),
  );
});

class EditFormNotifier extends StateNotifier<EditFormState> {
  EditFormNotifier(this._orderId, this._ref)
      : super(const EditFormState()) {
    _load();
  }

  Future<void> load() async => _load();

  final String _orderId;
  final Ref _ref;

  Future<void> _load() async {
    final repo = _ref.read(orderEditPreferencesRepositoryProvider);
    final result = await repo.getCarPreferences(_orderId);
    result.fold(
      (_) => state = state.copyWith(error: 'Could not load preferences'),
      (data) {
        if (data == null) return;
        final make = (data['make'] as String?) ?? 'Toyota';
        final model = (data['model'] as String?) ?? 'Camry';
        final yearMin = (data['yearMin'] as int?) ?? 2019;
        final yearMax = (data['yearMax'] as int?) ?? 2019;
        final conditionStr =
            (data['condition'] as String?) ??
                FirestoreEnumValues.vehicleConditionRunAndDrive;
        final conditionLabel =
            (data['conditionLabel'] as String?) ?? 'Ready to drive';
        final maxMileage = (data['maxMileage'] as int?) ?? 70000;
        final repairOptedIn = (data['repairOptedIn'] as bool?) ?? true;
        final condition = _conditionFromFirestore(conditionStr);
        final prefId = data['id'] as String?;
        state = EditFormState(
          preferenceId: prefId,
          make: make,
          model: model,
          yearMin: yearMin,
          yearMax: yearMax,
          condition: condition,
          maxMileage: maxMileage,
          repairOptedIn: repairOptedIn,
          originalValues: _formValuesFromState(
            make: make,
            model: model,
            yearMin: yearMin,
            yearMax: yearMax,
            condition: conditionStr,
            conditionLabel: conditionLabel,
            maxMileage: maxMileage,
            repairOptedIn: repairOptedIn,
          ),
        );
      },
    );
  }

  Future<bool> save(String userId) async {
    final o = state.originalValues;
    final prefId = state.preferenceId;
    if (o == null || prefId == null || !_hasChanges(state)) return false;
    state = state.copyWith(isSaving: true, error: null);
    final repo = _ref.read(orderEditPreferencesRepositoryProvider);
    final newValues = <String, dynamic>{
      'make': state.make,
      'model': state.model,
      'yearMin': state.yearMin,
      'yearMax': state.yearMax,
      'isSingleYear': state.isSingleYear,
      'condition': _conditionToFirestore(state.condition),
      'conditionLabel': _conditionLabel(state.condition),
      'maxMileage': state.maxMileage,
      'repairOptedIn': state.repairOptedIn,
    };
    final originalMap = <String, dynamic>{
      'make': o.make,
      'model': o.model,
      'yearMin': o.yearMin,
      'yearMax': o.yearMax,
      'isSingleYear': o.yearMin == o.yearMax,
      'condition': o.condition,
      'conditionLabel': o.conditionLabel,
      'maxMileage': o.maxMileage,
      'repairOptedIn': o.repairOptedIn,
    };
    final result = await repo.updateCarPreferencesAndNotify(
      orderId: _orderId,
      preferenceId: prefId,
      newValues: newValues,
      originalValues: originalMap,
      editedByUserId: userId,
    );
    state = state.copyWith(isSaving: false);
    return result.fold(
      (f) {
        state = state.copyWith(error: f.message);
        return false;
      },
      (_) => true,
    );
  }

  void updateMake(String make, List<String> models) {
    state = state.copyWith(make: make, model: models.isNotEmpty ? models.first : state.model);
  }

  void updateModel(String model) => state = state.copyWith(model: model);

  void updateYearMin(int v) {
    final yearMax = state.yearMax < v ? v : state.yearMax;
    state = state.copyWith(yearMin: v, yearMax: yearMax);
  }

  void updateYearMax(int v) {
    final newMax = v < state.yearMin ? state.yearMin : v;
    state = state.copyWith(yearMax: newMax);
  }

  void updateCondition(PreferenceCondition c) =>
      state = state.copyWith(condition: c);

  void updateMaxMileage(int v) => state = state.copyWith(maxMileage: v);

  void updateRepairOptedIn(bool v) => state = state.copyWith(repairOptedIn: v);
}

extension _EditFormStateX on EditFormState {
  EditFormState copyWith({
    String? preferenceId,
    String? make,
    String? model,
    int? yearMin,
    int? yearMax,
    PreferenceCondition? condition,
    int? maxMileage,
    bool? repairOptedIn,
    EditFormValues? originalValues,
    bool? isSaving,
    String? error,
  }) =>
      EditFormState(
        preferenceId: preferenceId ?? this.preferenceId,
        make: make ?? this.make,
        model: model ?? this.model,
        yearMin: yearMin ?? this.yearMin,
        yearMax: yearMax ?? this.yearMax,
        condition: condition ?? this.condition,
        maxMileage: maxMileage ?? this.maxMileage,
        repairOptedIn: repairOptedIn ?? this.repairOptedIn,
        originalValues: originalValues ?? this.originalValues,
        isSaving: isSaving ?? this.isSaving,
        error: error,
      );
}

final editFormNotifierProvider =
    StateNotifierProvider.family<EditFormNotifier, EditFormState, String>(
  (ref, orderId) => EditFormNotifier(orderId, ref),
);

bool _hasChanges(EditFormState state) {
  final o = state.originalValues;
  if (o == null) return false;
  final cStr = _conditionToFirestore(state.condition);
  final cLabel = _conditionLabel(state.condition);
  return state.make != o.make ||
      state.model != o.model ||
      state.yearMin != o.yearMin ||
      state.yearMax != o.yearMax ||
      cStr != o.condition ||
      cLabel != o.conditionLabel ||
      state.maxMileage != o.maxMileage ||
      state.repairOptedIn != o.repairOptedIn;
}

final hasChangesProvider = Provider.family<bool, String>((ref, orderId) {
  final state = ref.watch(editFormNotifierProvider(orderId));
  return _hasChanges(state);
});
