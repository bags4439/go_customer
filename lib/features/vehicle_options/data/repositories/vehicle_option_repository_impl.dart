import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/buyer_vehicle_response.dart';
import '../../domain/entities/vehicle_option.dart' as domain;
import '../../domain/repositories/vehicle_option_repository.dart';
import '../datasources/vehicle_option_firestore_data_source.dart';
import '../models/vehicle_option_model.dart';

class VehicleOptionRepositoryImpl implements VehicleOptionRepository {
  VehicleOptionRepositoryImpl(this._dataSource, this._functions);

  final VehicleOptionFirestoreDataSource _dataSource;
  final FirebaseFunctions _functions;

  @override
  Stream<Either<Failure, List<domain.VehicleOption>>> watchSentOptionsForOrder(
    String orderId,
  ) {
    return _dataSource.watchSentOptionsForOrder(orderId).transform(
      StreamTransformer<List<VehicleOptionModel>, Either<Failure, List<domain.VehicleOption>>>.fromHandlers(
        handleData: (models, sink) => sink.add(
          Right(models.map((model) => model.toEntity()).toList(growable: false)),
        ),
        handleError: (Object error, StackTrace stackTrace, sink) {
          sink.add(
            Left(
              FirestoreFailure(message: error.toString(), cause: error),
            ),
          );
        },
      ),
    );
  }

  @override
  Stream<Either<Failure, domain.VehicleOption?>> watchVehicleOption(
    String vehicleOptionId,
  ) {
    return _dataSource.watchVehicleOption(vehicleOptionId).transform(
      StreamTransformer<VehicleOptionModel?, Either<Failure, domain.VehicleOption?>>.fromHandlers(
        handleData: (model, sink) =>
            sink.add(Right(model?.toEntity())),
        handleError: (Object error, StackTrace stackTrace, sink) {
          sink.add(
            Left(
              FirestoreFailure(message: error.toString(), cause: error),
            ),
          );
        },
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> respondToVehicleOption({
    required String vehicleOptionId,
    required BuyerVehicleResponse response,
  }) async {
    try {
      await _functions.httpsCallable('respondToVehicleOption').call({
        'vehicleOptionId': vehicleOptionId,
        'response': response.name,
      });
      return const Right(unit);
    } on FirebaseFunctionsException catch (e) {
      return Left(FirestoreFailure(message: e.message ?? e.code));
    } catch (e) {
      return Left(FirestoreFailure(message: e.toString(), cause: e));
    }
  }
}
