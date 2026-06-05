import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/vehicle_option.dart';
import '../repositories/vehicle_option_repository.dart';

class WatchVehicleOptionUseCase {
  const WatchVehicleOptionUseCase(this._repository);

  final VehicleOptionRepository _repository;

  Stream<Either<Failure, VehicleOption?>> call(String vehicleOptionId) =>
      _repository.watchVehicleOption(vehicleOptionId);
}
