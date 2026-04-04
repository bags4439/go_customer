import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/delivery.dart';
import '../../domain/repositories/delivery_repository.dart';
import '../datasources/delivery_firestore_data_source.dart';

class DeliveryRepositoryImpl implements DeliveryRepository {
  DeliveryRepositoryImpl(this._ds);

  final DeliveryFirestoreDataSource _ds;

  @override
  Stream<Either<Failure, Delivery?>> watchDelivery(String orderId) {
    return _ds.watchDelivery(orderId).transform(
      StreamTransformer<Delivery?, Either<Failure, Delivery?>>.fromHandlers(
        handleData: (data, sink) =>
            sink.add(Right<Failure, Delivery?>(data)),
        handleError: (Object error, StackTrace stackTrace, sink) {
          sink.add(
            Left<Failure, Delivery?>(
              FirestoreFailure(message: error.toString(), cause: error),
            ),
          );
        },
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> saveDeliveryLocation({
    required String orderId,
    required String address,
    required String city,
    required String locationSource,
    double? latitude,
    double? longitude,
    String? locationLabel,
  }) async {
    try {
      await _ds.saveDeliveryLocation(
        orderId: orderId,
        address: address,
        city: city,
        locationSource: locationSource,
        latitude: latitude,
        longitude: longitude,
        locationLabel: locationLabel,
      );
      return const Right(unit);
    } catch (e) {
      return Left(
        FirestoreFailure(message: e.toString(), cause: e),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> confirmDelivery(String orderId) async {
    try {
      await _ds.confirmDelivery(orderId);
      return const Right(unit);
    } catch (e) {
      return Left(
        FirestoreFailure(message: e.toString(), cause: e),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> submitReviewAndClose({
    required String orderId,
    required String buyerId,
    required String agentId,
    required double overallRating,
    required double agentRating,
    required double communicationRating,
    required double speedRating,
    String? comment,
  }) async {
    try {
      await _ds.submitReviewAndClose(
        orderId: orderId,
        buyerId: buyerId,
        agentId: agentId,
        overallRating: overallRating,
        agentRating: agentRating,
        communicationRating: communicationRating,
        speedRating: speedRating,
        comment: comment,
      );
      return const Right(unit);
    } catch (e) {
      return Left(
        FirestoreFailure(message: e.toString(), cause: e),
      );
    }
  }
}
