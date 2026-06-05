/// Agent lifecycle for a vehicle option shared with the buyer.
enum VehicleOptionStatus {
  draft,
  sent,
  withdrawn;

  static VehicleOptionStatus fromString(String? value) {
    return VehicleOptionStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => VehicleOptionStatus.draft,
    );
  }
}
