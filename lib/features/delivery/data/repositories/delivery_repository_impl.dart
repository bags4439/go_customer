import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../orders/data/models/buyer_review_model.dart';
import '../../domain/entities/delivery.dart';
import '../../domain/repositories/delivery_repository.dart';
import '../datasources/delivery_firestore_data_source.dart';

class DeliveryRepositoryImpl implements DeliveryRepository {
  DeliveryRepositoryImpl(this._ds, this._functions);

  final DeliveryFirestoreDataSource _ds;
  final FirebaseFunctions _functions;

  Future<void> _call(String name, Map<String, dynamic> data) async {
    await _functions.httpsCallable(name).call(data);
  }

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
  Stream<Either<Failure, BuyerReviewModel?>> watchReview({
    required String orderId,
    required String buyerId,
  }) {
    return _ds
        .watchReview(
          orderId: orderId,
          buyerId: buyerId,
        )
        .transform(
          StreamTransformer<BuyerReviewModel?, Either<Failure, BuyerReviewModel?>>.fromHandlers(
            handleData: (data, sink) =>
                sink.add(Right<Failure, BuyerReviewModel?>(data)),
            handleError: (
              Object error,
              StackTrace stackTrace,
              sink,
            ) {
              sink.add(
                Left<Failure, BuyerReviewModel?>(
                  FirestoreFailure(
                    message: error.toString(),
                    cause: error,
                  ),
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
      await _call('saveBuyerDeliveryLocation', {
        'orderId': orderId,
        'address': address,
        'city': city,
        'locationSource': locationSource,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (locationLabel != null) 'locationLabel': locationLabel,
      });
      return const Right(unit);
    } on FirebaseFunctionsException catch (e) {
      return Left(FirestoreFailure(message: e.message ?? e.code));
    } catch (e) {
      return Left(FirestoreFailure(message: e.toString(), cause: e));
    }
  }

  @override
  Future<Either<Failure, Unit>> confirmDelivery(String orderId) async {
    try {
      await _call('confirmBuyerReceipt', {'orderId': orderId});
      return const Right(unit);
    } on FirebaseFunctionsException catch (e) {
      return Left(FirestoreFailure(message: e.message ?? e.code));
    } catch (e) {
      return Left(FirestoreFailure(message: e.toString(), cause: e));
    }
  }

  @override
  Future<Either<Failure, Unit>> confirmAgentDelivery(String orderId) async {
    try {
      await _call('submitBuyerDeliveryChoice', {
        'orderId': orderId,
        'handledBy': 'agent',
      });
      return const Right(unit);
    } on FirebaseFunctionsException catch (e) {
      return Left(FirestoreFailure(message: e.message ?? e.code));
    } catch (e) {
      return Left(FirestoreFailure(message: e.toString(), cause: e));
    }
  }

  @override
  Future<Either<Failure, Unit>> confirmSelfPickup(String orderId) async {
    try {
      await _call('submitBuyerDeliveryChoice', {
        'orderId': orderId,
        'handledBy': 'self',
      });
      return const Right(unit);
    } on FirebaseFunctionsException catch (e) {
      return Left(FirestoreFailure(message: e.message ?? e.code));
    } catch (e) {
      return Left(FirestoreFailure(message: e.toString(), cause: e));
    }
  }

  @override
  Future<Either<Failure, Unit>> confirmSelfCollection(String orderId) async {
    try {
      await _call('confirmBuyerReceipt', {'orderId': orderId});
      return const Right(unit);
    } on FirebaseFunctionsException catch (e) {
      return Left(FirestoreFailure(message: e.message ?? e.code));
    } catch (e) {
      return Left(FirestoreFailure(message: e.toString(), cause: e));
    }
  }

  @override
  Future<Either<Failure, Unit>> submitReviewAndClose({
    required String orderId,
    required String buyerId,
    required String agentId,
    required double overallRating,
    String? comment,
  }) async {
    try {
      await _call('submitBuyerReview', {
        'orderId': orderId,
        'overallRating': overallRating,
        if (comment != null && comment.trim().isNotEmpty)
          'comment': comment.trim(),
      });
      return const Right(unit);
    } on FirebaseFunctionsException catch (e) {
      return Left(FirestoreFailure(message: e.message ?? e.code));
    } catch (e) {
      return Left(FirestoreFailure(message: e.toString(), cause: e));
    }
  }
}
