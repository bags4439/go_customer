import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../data/repositories/preferences_repository_impl.dart';
import '../../domain/repositories/preferences_repository.dart';
import '../../../../shared/providers/firebase_providers.dart';
import 'preference_form_provider.dart';

const _undefined = Object();

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
  final String purchaseOrigin;
  final String? trim;
  final String? makeSlug;
  final String? modelSlug;
  final bool isNewVehicle;

  const EditFormValues({
    required this.make,
    required this.model,
    required this.yearMin,
    required this.yearMax,
    required this.condition,
    required this.conditionLabel,
    required this.maxMileage,
    required this.repairOptedIn,
    required this.purchaseOrigin,
    this.trim,
    this.makeSlug,
    this.modelSlug,
    required this.isNewVehicle,
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
  final String purchaseOrigin;
  final String? trim;
  final String? makeSlug;
  final String? modelSlug;
  final bool isNewVehicle;
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
    this.purchaseOrigin = AppConstants.purchaseOriginAny,
    this.trim,
    this.makeSlug,
    this.modelSlug,
    this.isNewVehicle = false,
    this.originalValues,
    this.isSaving = false,
    this.error,
  });

  bool get isSingleYear => yearMin == yearMax;

  bool get isChina => purchaseOrigin == AppConstants.purchaseOriginChina;

  bool get isUsOrDubai =>
      purchaseOrigin == AppConstants.purchaseOriginUsCanada ||
      purchaseOrigin == AppConstants.purchaseOriginDubai ||
      purchaseOrigin == AppConstants.purchaseOriginAny;

  bool get isBrandNewVehicle =>
      isNewVehicle || condition == PreferenceCondition.newVehicle;
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
  required String purchaseOrigin,
  String? trim,
  String? makeSlug,
  String? modelSlug,
  required bool isNewVehicle,
}) => EditFormValues(
  make: make,
  model: model,
  yearMin: yearMin,
  yearMax: yearMax,
  condition: condition,
  conditionLabel: conditionLabel,
  maxMileage: maxMileage,
  repairOptedIn: repairOptedIn,
  purchaseOrigin: purchaseOrigin,
  trim: trim,
  makeSlug: makeSlug,
  modelSlug: modelSlug,
  isNewVehicle: isNewVehicle,
);

final orderEditPreferencesRepositoryProvider = Provider<PreferencesRepository>((
  ref,
) {
  return PreferencesRepositoryImpl(
    ref.watch(preferencesDataSourceProvider),
    ref.watch(functionsProvider),
  );
});

class EditFormNotifier extends StateNotifier<EditFormState> {
  EditFormNotifier(this._orderId, this._ref) : super(const EditFormState()) {
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
        final purchaseOrigin =
            (data['purchaseOrigin'] as String?) ??
            AppConstants.purchaseOriginAny;
        final trim = data['trim'] as String?;
        final makeSlug = data['makeSlug'] as String?;
        final modelSlug = data['modelSlug'] as String?;
        final isNewVehicle = (data['isNewVehicle'] as bool?) ?? false;
        final condition = PreferenceCondition.fromString(conditionStr);
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
          purchaseOrigin: purchaseOrigin,
          trim: trim,
          makeSlug: makeSlug,
          modelSlug: modelSlug,
          isNewVehicle: isNewVehicle,
          originalValues: _formValuesFromState(
            make: make,
            model: model,
            yearMin: yearMin,
            yearMax: yearMax,
            condition: conditionStr,
            conditionLabel: conditionLabel,
            maxMileage: maxMileage,
            repairOptedIn: repairOptedIn,
            purchaseOrigin: purchaseOrigin,
            trim: trim,
            makeSlug: makeSlug,
            modelSlug: modelSlug,
            isNewVehicle: isNewVehicle,
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
      'condition': preferenceConditionToFirestoreString(state.condition),
      'conditionLabel': preferenceConditionUiLabel(state.condition),
      'maxMileage': state.maxMileage,
      'repairOptedIn': state.repairOptedIn,
      'trim': state.trim,
      'purchaseOrigin': state.purchaseOrigin,
      'isNewVehicle': state.isNewVehicle,
      'makeSlug': state.makeSlug,
      'modelSlug': state.modelSlug,
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
      'trim': o.trim,
      'purchaseOrigin': o.purchaseOrigin,
      'isNewVehicle': o.isNewVehicle,
      'makeSlug': o.makeSlug,
      'modelSlug': o.modelSlug,
    };
    final result = await repo.updateCarPreferencesAndNotify(
      orderId: _orderId,
      preferenceId: prefId,
      newValues: newValues,
      originalValues: originalMap,
      editedByUserId: userId,
    );
    state = state.copyWith(isSaving: false);
    return result.fold((f) {
      state = state.copyWith(error: f.message);
      return false;
    }, (_) => true);
  }

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
      condition: newCondition != null
          ? PreferenceCondition.fromString(newCondition)
          : state.condition,
      maxMileage: newMileage ?? state.maxMileage,
    );
  }

  void updateTrim(String? value) {
    state = state.copyWith(trim: value);
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

  void updateMake(String make, List<String> models) {
    state = state.copyWith(
      make: make,
      model: models.isNotEmpty ? models.first : state.model,
      trim: null,
      modelSlug: null,
    );
  }

  void updateModel(String model) {
    state = state.copyWith(model: model, trim: null, modelSlug: null);
  }

  void updateYearMin(int v) {
    final yearMax = state.yearMax < v ? v : state.yearMax;
    state = state.copyWith(yearMin: v, yearMax: yearMax);
  }

  void updateYearMax(int v) {
    final newMax = v < state.yearMin ? state.yearMin : v;
    state = state.copyWith(yearMax: newMax);
  }

  void updateCondition(PreferenceCondition c) {
    state = state.copyWith(
      condition: c,
      isNewVehicle: c == PreferenceCondition.newVehicle,
    );
  }

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
    String? purchaseOrigin,
    Object? trim = _undefined,
    Object? makeSlug = _undefined,
    Object? modelSlug = _undefined,
    bool? isNewVehicle,
    EditFormValues? originalValues,
    bool? isSaving,
    String? error,
  }) => EditFormState(
    preferenceId: preferenceId ?? this.preferenceId,
    make: make ?? this.make,
    model: model ?? this.model,
    yearMin: yearMin ?? this.yearMin,
    yearMax: yearMax ?? this.yearMax,
    condition: condition ?? this.condition,
    maxMileage: maxMileage ?? this.maxMileage,
    repairOptedIn: repairOptedIn ?? this.repairOptedIn,
    purchaseOrigin: purchaseOrigin ?? this.purchaseOrigin,
    trim: identical(trim, _undefined) ? this.trim : trim as String?,
    makeSlug: identical(makeSlug, _undefined)
        ? this.makeSlug
        : makeSlug as String?,
    modelSlug: identical(modelSlug, _undefined)
        ? this.modelSlug
        : modelSlug as String?,
    isNewVehicle: isNewVehicle ?? this.isNewVehicle,
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
  final cStr = preferenceConditionToFirestoreString(state.condition);
  final cLabel = preferenceConditionUiLabel(state.condition);
  return state.make != o.make ||
      state.model != o.model ||
      state.yearMin != o.yearMin ||
      state.yearMax != o.yearMax ||
      cStr != o.condition ||
      cLabel != o.conditionLabel ||
      state.maxMileage != o.maxMileage ||
      state.repairOptedIn != o.repairOptedIn ||
      state.purchaseOrigin != o.purchaseOrigin ||
      state.trim != o.trim ||
      state.makeSlug != o.makeSlug ||
      state.modelSlug != o.modelSlug ||
      state.isNewVehicle != o.isNewVehicle;
}

final hasChangesProvider = Provider.family<bool, String>((ref, orderId) {
  final state = ref.watch(editFormNotifierProvider(orderId));
  return _hasChanges(state);
});
