import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/repair_job.dart';
import '../../domain/repositories/repair_repository.dart';
import '../datasources/repair_firestore_data_source.dart';

class RepairRepositoryImpl implements RepairRepository {
  final RepairFirestoreDataSource _dataSource;
  final FirebaseFunctions _functions;

  RepairRepositoryImpl(this._dataSource, this._functions);

  @override
  Stream<RepairJob?> watchRepairJob(String orderId) {
    return _dataSource.watchRepairJob(orderId);
  }

  @override
  Future<Either<Failure, Unit>> confirmRepairs({
    required String orderId,
    required bool optedIn,
  }) async {
    try {
      final existing = await _dataSource.getRepairJob(orderId);
      if (existing != null) return const Right(unit);
      await _dataSource.confirmRepairsOptIn(orderId, optedIn);
      try {
        await _functions.httpsCallable('notifyAgentRepairChoice').call({
          'orderId': orderId,
          'optedIn': optedIn,
        });
      } catch (_) {}
      return const Right(unit);
    } catch (e, st) {
      return Left(FirestoreFailure(message: e.toString(), cause: st));
    }
  }

  @override
  Future<Either<Failure, Unit>> acceptQuote(String orderId) async {
    try {
      await _dataSource.acceptQuote(orderId);
      try {
        await _functions.httpsCallable('onRepairQuoteAccepted').call({'orderId': orderId});
      } catch (_) {}
      return const Right(unit);
    } catch (e, st) {
      return Left(FirestoreFailure(message: e.toString(), cause: st));
    }
  }

  @override
  Future<Either<Failure, Unit>> declineQuote(String orderId) async {
    try {
      await _dataSource.declineQuote(orderId);
      try {
        await _functions.httpsCallable('onRepairQuoteDeclined').call({'orderId': orderId});
      } catch (_) {}
      return const Right(unit);
    } catch (e, st) {
      return Left(FirestoreFailure(message: e.toString(), cause: st));
    }
  }

  @override
  Future<Either<Failure, Unit>> switchToRepairs(String orderId) async {
    try {
      await _dataSource.switchToRepairs(orderId);
      try {
        await _functions.httpsCallable('notifyAgentRepairChoice').call({
          'orderId': orderId,
          'optedIn': true,
        });
      } catch (_) {}
      return const Right(unit);
    } catch (e, st) {
      return Left(FirestoreFailure(message: e.toString(), cause: st));
    }
  }
}
