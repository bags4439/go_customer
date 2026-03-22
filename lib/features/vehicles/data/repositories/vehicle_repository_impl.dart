import 'package:cloud_functions/cloud_functions.dart';

import '../../../vehicle_options/data/models/max_bid_model.dart';
import '../../../vehicle_options/data/models/vehicle_option_model.dart';
import '../../domain/entities/max_bid_entity.dart';
import '../../domain/entities/vehicle_option_entity.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/vehicle_firestore_data_source.dart';
class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleFirestoreDataSource _dataSource;
  final FirebaseFunctions _functions;

  const VehicleRepositoryImpl(this._dataSource, this._functions);

  @override
  Future<VehicleOptionEntity?> getVehicleOption(String vehicleOptionId) async {
    final model = await _dataSource.getVehicleOption(vehicleOptionId);
    return model?.toEntity();
  }

  @override
  Future<MaxBidEntity?> getExistingMaxBid({
    required String vehicleOptionId,
    required String buyerId,
  }) async {
    final model = await _dataSource.getExistingMaxBid(
      vehicleOptionId: vehicleOptionId,
      buyerId: buyerId,
    );
    return model?.toEntity();
  }

  @override
  Future<void> confirmMaxBid({
    required String orderId,
    required String vehicleOptionId,
    required String buyerId,
    required double maxBidUsd,
    required double maxBidGhs,
    required double exchangeRate,
  }) async {
    await _dataSource.createMaxBid(
      orderId: orderId,
      vehicleOptionId: vehicleOptionId,
      buyerId: buyerId,
      maxBidUsd: maxBidUsd,
      maxBidGhs: maxBidGhs,
      exchangeRate: exchangeRate,
    );
    await _dataSource.updateVehicleOptionConfirmed(vehicleOptionId);
    await _dataSource.updateOrderBidPlaced(orderId);
    await _functions.httpsCallable('onMaxBidConfirmed').call({
      'orderId': orderId,
      'vehicleOptionId': vehicleOptionId,
    });
  }
}
