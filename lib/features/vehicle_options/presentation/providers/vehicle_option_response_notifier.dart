import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/buyer_vehicle_response.dart';
import 'vehicle_option_providers.dart';

enum VehicleOptionResponseStatus { idle, submitting, error }

class VehicleOptionResponseNotifier
    extends StateNotifier<VehicleOptionResponseStatus> {
  VehicleOptionResponseNotifier(this._ref) : super(VehicleOptionResponseStatus.idle);

  final Ref _ref;
  String? _lastError;

  String? get lastError => _lastError;

  Future<bool> submit({
    required String vehicleOptionId,
    required BuyerVehicleResponse response,
  }) async {
    _lastError = null;
    state = VehicleOptionResponseStatus.submitting;
    final useCase = _ref.read(respondToVehicleOptionUseCaseProvider);
    final result = await useCase(
      vehicleOptionId: vehicleOptionId,
      response: response,
    );
    return result.fold(
      (failure) {
        _lastError = failure.message;
        state = VehicleOptionResponseStatus.error;
        return false;
      },
      (_) {
        state = VehicleOptionResponseStatus.idle;
        return true;
      },
    );
  }

  void clearError() {
    _lastError = null;
    if (state == VehicleOptionResponseStatus.error) {
      state = VehicleOptionResponseStatus.idle;
    }
  }
}

final vehicleOptionResponseNotifierProvider = StateNotifierProvider.autoDispose
    .family<VehicleOptionResponseNotifier, VehicleOptionResponseStatus, String>(
  (ref, vehicleOptionId) => VehicleOptionResponseNotifier(ref),
);
