import '../../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/repair_job.dart';

abstract class RepairRepository {
  Stream<RepairJob?> watchRepairJob(String orderId);
  Future<Either<Failure, Unit>> confirmRepairs({
    required String orderId,
    required bool optedIn,
  });
  Future<Either<Failure, Unit>> acceptQuote(String orderId);
  Future<Either<Failure, Unit>> declineQuote(String orderId);
  Future<Either<Failure, Unit>> switchToRepairs(String orderId);
}
