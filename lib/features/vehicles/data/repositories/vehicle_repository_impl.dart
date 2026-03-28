import '../../domain/entities/vehicle_option_entity.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/vehicle_firestore_data_source.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleFirestoreDataSource _dataSource;

  const VehicleRepositoryImpl(this._dataSource);

  @override
  Future<VehicleOptionEntity?> getVehicleOption(String vehicleOptionId) async {
    final model = await _dataSource.getVehicleOption(vehicleOptionId);
    return model?.toEntity();
  }
}
