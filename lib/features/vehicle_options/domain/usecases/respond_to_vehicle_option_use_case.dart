import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/buyer_vehicle_response.dart';
import '../repositories/vehicle_option_repository.dart';

class RespondToVehicleOptionUseCase {
  const RespondToVehicleOptionUseCase(this._repository);

  final VehicleOptionRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String vehicleOptionId,
    required BuyerVehicleResponse response,
  }) =>
      _repository.respondToVehicleOption(
        vehicleOptionId: vehicleOptionId,
        response: response,
      );
}
