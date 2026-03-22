import '../entities/max_bid_entity.dart';
import '../entities/vehicle_option_entity.dart';

abstract class VehicleRepository {
  Future<VehicleOptionEntity?> getVehicleOption(String vehicleOptionId);

  Future<MaxBidEntity?> getExistingMaxBid({
    required String vehicleOptionId,
    required String buyerId,
  });

  Future<void> confirmMaxBid({
    required String orderId,
    required String vehicleOptionId,
    required String buyerId,
    required double maxBidUsd,
    required double maxBidGhs,
    required double exchangeRate,
  });
}
