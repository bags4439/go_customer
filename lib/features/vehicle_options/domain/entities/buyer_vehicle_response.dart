/// Buyer's non-binding interest signal on a vehicle listing.
enum BuyerVehicleResponse {
  pending,
  interested,
  declined;

  static BuyerVehicleResponse fromString(String? value) {
    return BuyerVehicleResponse.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BuyerVehicleResponse.pending,
    );
  }
}
