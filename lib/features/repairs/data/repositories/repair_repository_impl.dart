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

  Future<void> _submitRepairChoice({
    required String orderId,
    required bool optedIn,
  }) async {
    await _functions.httpsCallable('notifyAgentRepairChoice').call({
      'orderId': orderId,
      'optedIn': optedIn,
    });
  }

  @override
  Future<Either<Failure, Unit>> confirmRepairs({
    required String orderId,
    required bool optedIn,
  }) async {
    try {
      await _submitRepairChoice(orderId: orderId, optedIn: optedIn);
      return const Right(unit);
    } on FirebaseFunctionsException catch (e) {
      return Left(FirestoreFailure(message: e.message ?? e.code));
    } catch (e, st) {
      return Left(FirestoreFailure(message: e.toString(), cause: st));
    }
  }

  @override
  Future<Either<Failure, Unit>> acceptQuote(String orderId) async {
    try {
      await _dataSource.acceptQuote(orderId);
      try {
        await _functions.httpsCallable('onRepairQuoteAccepted').call({
          'orderId': orderId,
        });
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
        await _functions.httpsCallable('onRepairQuoteDeclined').call({
          'orderId': orderId,
        });
      } catch (_) {}
      return const Right(unit);
    } catch (e, st) {
      return Left(FirestoreFailure(message: e.toString(), cause: st));
    }
  }

  @override
  Future<Either<Failure, Unit>> switchToRepairs(String orderId) async {
    try {
      await _submitRepairChoice(orderId: orderId, optedIn: true);
      return const Right(unit);
    } on FirebaseFunctionsException catch (e) {
      return Left(FirestoreFailure(message: e.message ?? e.code));
    } catch (e, st) {
      return Left(FirestoreFailure(message: e.toString(), cause: st));
    }
  }
}
