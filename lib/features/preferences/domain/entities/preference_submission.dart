class PreferenceSubmission {
  final String make;
  final String model;
  final int yearMin;
  final int yearMax;
  final String condition;
  final String conditionLabel;
  final int maxMileage;
  final String? trim;
  final String purchaseOrigin;
  final bool isNewVehicle;
  final int? maxBudgetUsd;

  /// GHS equivalent snapshot at order creation (derived from [maxBudgetUsd]).
  final int? maxBudgetGhs;

  const PreferenceSubmission({
    required this.make,
    required this.model,
    required this.yearMin,
    required this.yearMax,
    required this.condition,
    required this.conditionLabel,
    required this.maxMileage,
    this.trim,
    this.purchaseOrigin = 'any',
    this.isNewVehicle = false,
    this.maxBudgetUsd,
    this.maxBudgetGhs,
  });
}
