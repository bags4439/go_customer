import '../../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/duty_clearance.dart';

abstract class DutyClearanceRepository {
  Stream<DutyClearance?> watchDutyClearance(String orderId);
  Future<Either<Failure, Unit>> confirmAgentClearance({
    required String orderId,
    required double clearanceFeeUsd,
  });
  Future<Either<Failure, Unit>> confirmSelfClearance(String orderId);
  Future<Either<Failure, Unit>> switchToAgentClearance({
    required String orderId,
    required double clearanceFeeUsd,
  });
}
