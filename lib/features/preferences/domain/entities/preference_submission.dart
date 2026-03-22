class PreferenceSubmission {
  final String make;
  final String model;
  final int yearMin;
  final int yearMax;
  final String condition;
  final String conditionLabel;
  final int maxMileage;
  final bool repairOptedIn;

  const PreferenceSubmission({
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

