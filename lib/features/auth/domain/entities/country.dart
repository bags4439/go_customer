/// Represents a supported country in the app.
/// Immutable value object — no business logic.
class Country {
  const Country({
    required this.isoCode,
    required this.name,
    required this.flag,
    required this.dialCode,
  });

  /// ISO 3166-1 alpha-2 code e.g. 'GH', 'US'
  final String isoCode;

  /// Display name e.g. 'Ghana'
  final String name;

  /// Flag emoji e.g. '🇬🇭'
  final String flag;

  /// Dial code e.g. '+233'
  final String dialCode;

  /// Display label shown in pickers and fields.
  /// e.g. '🇬🇭  Ghana'
  String get displayLabel => '$flag  $name';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Country &&
          runtimeType == other.runtimeType &&
          isoCode == other.isoCode;

  @override
  int get hashCode => isoCode.hashCode;
}
