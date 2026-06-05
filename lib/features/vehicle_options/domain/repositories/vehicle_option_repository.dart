import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/buyer_vehicle_response.dart';
import '../entities/vehicle_option.dart';

abstract class VehicleOptionRepository {
  Stream<Either<Failure, List<VehicleOption>>> watchSentOptionsForOrder(
    String orderId,
  );

  Stream<Either<Failure, VehicleOption?>> watchVehicleOption(
    String vehicleOptionId,
  );

  Future<Either<Failure, Unit>> respondToVehicleOption({
    required String vehicleOptionId,
    required BuyerVehicleResponse response,
  });
}
