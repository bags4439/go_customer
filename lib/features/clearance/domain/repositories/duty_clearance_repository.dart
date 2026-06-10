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

  /// Best-effort backfill when duty_clearance exists but the agent
  /// was never notified (e.g. callable failed on wrong region).
  Future<Either<Failure, Unit>> syncAgentClearanceNotification({
    required String orderId,
    required String choice,
    bool switched = false,
  });
}
