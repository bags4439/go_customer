import '../entities/vehicle_option_entity.dart';

abstract class VehicleRepository {
  Future<VehicleOptionEntity?> getVehicleOption(String vehicleOptionId);
}
