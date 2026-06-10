import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/crash_reporter.dart';
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

  Future<void> _notifyAgentClearanceChoice({
    required String orderId,
    required String choice,
    bool switched = false,
  }) async {
    try {
      await _functions.httpsCallable('notifyAgentClearanceChoice').call({
        'orderId': orderId,
        'choice': choice,
        if (switched) 'switched': true,
      });
    } catch (error, stackTrace) {
      // Firestore already committed; log for ops visibility.
      await CrashReporter.reportError(
        error,
        stackTrace: stackTrace,
        context: 'notifyAgentClearanceChoice orderId=$orderId choice=$choice',
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> syncAgentClearanceNotification({
    required String orderId,
    required String choice,
    bool switched = false,
  }) async {
    try {
      await _notifyAgentClearanceChoice(
        orderId: orderId,
        choice: choice,
        switched: switched,
      );
      return const Right(unit);
    } catch (e, st) {
      return Left(FirestoreFailure(message: e.toString(), cause: st));
    }
  }

  @override
  Future<Either<Failure, Unit>> confirmAgentClearance({
    required String orderId,
    required double clearanceFeeUsd,
  }) async {
    try {
      final existing = await _dataSource.getDutyClearance(orderId);
      if (existing != null) {
        if (existing.isAgentHandled) {
          await _notifyAgentClearanceChoice(
            orderId: orderId,
            choice: 'agent',
          );
        }
        return const Right(unit);
      }
      await _dataSource.confirmAgentClearance(
        orderId: orderId,
        clearanceFeeUsd: clearanceFeeUsd,
      );
      await _notifyAgentClearanceChoice(
        orderId: orderId,
        choice: 'agent',
      );
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
      await _notifyAgentClearanceChoice(
        orderId: orderId,
        choice: 'self',
      );
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
      await _notifyAgentClearanceChoice(
        orderId: orderId,
        choice: 'agent',
        switched: true,
      );
      return const Right(unit);
    } catch (e, st) {
      return Left(FirestoreFailure(message: e.toString(), cause: st));
    }
  }
}
