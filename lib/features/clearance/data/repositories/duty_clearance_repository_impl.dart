import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/duty_clearance.dart';
import '../../domain/repositories/duty_clearance_repository.dart';
import '../datasources/clearance_firestore_data_source.dart';

class DutyClearanceRepositoryImpl implements DutyClearanceRepository {
  final ClearanceFirestoreDataSource _dataSource;
  final FirebaseFunctions _functions;

  DutyClearanceRepositoryImpl(this._dataSource, this._functions);

  @override
  Stream<DutyClearance?> watchDutyClearance(String orderId) {
    return _dataSource.watchDutyClearance(orderId);
  }

  @override
  Future<Either<Failure, Unit>> confirmAgentClearance({
    required String orderId,
    required double clearanceFeeUsd,
  }) async {
    try {
      final existing = await _dataSource.getDutyClearance(orderId);
      if (existing != null) {
        return const Right(unit);
      }
      await _dataSource.confirmAgentClearance(
        orderId: orderId,
        clearanceFeeUsd: clearanceFeeUsd,
      );
      try {
        await _functions.httpsCallable('notifyAgentClearanceChoice').call({
          'orderId': orderId,
          'choice': 'agent',
        });
      } catch (_) {
        // Firestore already committed; notification is best-effort
      }
      return const Right(unit);
    } catch (e, st) {
      return Left(FirestoreFailure(message: e.toString(), cause: st));
    }
  }

  @override
  Future<Either<Failure, Unit>> confirmSelfClearance(String orderId) async {
    try {
      final existing = await _dataSource.getDutyClearance(orderId);
      if (existing != null) {
        return const Right(unit);
      }
      await _dataSource.confirmSelfClearance(orderId);
      return const Right(unit);
    } catch (e, st) {
      return Left(FirestoreFailure(message: e.toString(), cause: st));
    }
  }

  @override
  Future<Either<Failure, Unit>> switchToAgentClearance({
    required String orderId,
    required double clearanceFeeUsd,
  }) async {
    try {
      await _dataSource.switchToAgentClearance(
        orderId: orderId,
        clearanceFeeUsd: clearanceFeeUsd,
      );
      try {
        await _functions.httpsCallable('notifyAgentClearanceChoice').call({
          'orderId': orderId,
          'choice': 'agent',
        });
      } catch (_) {}
      return const Right(unit);
    } catch (e, st) {
      return Left(FirestoreFailure(message: e.toString(), cause: st));
    }
  }
}
