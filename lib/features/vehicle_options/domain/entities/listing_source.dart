/// Where the agent found this vehicle option (agent-specified).
enum ListingSource {
  copart,
  iaa,
  dealer,
  other;

  String get displayLabel => switch (this) {
        ListingSource.copart => 'Copart',
        ListingSource.iaa => 'IAA',
        ListingSource.dealer => 'Dealer',
        ListingSource.other => 'Other',
      };

  static ListingSource? fromString(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return ListingSource.values.firstWhere(
      (e) => e.name == value.trim().toLowerCase(),
      orElse: () => ListingSource.other,
    );
  }
}
