import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/firebase_providers.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../../shipping/presentation/providers/shipping_providers.dart';
import '../../data/datasources/clearance_firestore_data_source.dart';
import '../../data/repositories/duty_clearance_repository_impl.dart';
import '../../domain/entities/duty_clearance.dart';
import '../../domain/repositories/duty_clearance_repository.dart';

/// Screen state for clearance route: which UI to show.
enum ClearanceScreenState {
  notAvailable,
  choicePending,
  agentManaged,
  selfCleared,
}

/// User selection on the choice screen (State 1).
enum ClearanceOption {
  agentHandles,
  selfClearance,
}

final clearanceDataSourceProvider = Provider<ClearanceFirestoreDataSource>((ref) {
  return ClearanceFirestoreDataSource(ref.watch(firestoreProvider));
});

final dutyClearanceRepositoryProvider = Provider<DutyClearanceRepository>((ref) {
  return DutyClearanceRepositoryImpl(
    ref.watch(clearanceDataSourceProvider),
    ref.watch(functionsProvider),
  );
});

final dutyClearanceProvider =
    StreamProvider.family<DutyClearance?, String>((ref, orderId) {
  return ref.watch(dutyClearanceRepositoryProvider).watchDutyClearance(orderId);
});

final clearanceScreenStateProvider =
    Provider.family<ClearanceScreenState, String>((ref, orderId) {
  final shipping = ref.watch(shippingProvider(orderId)).valueOrNull;
  final duty = ref.watch(dutyClearanceProvider(orderId)).valueOrNull;

  if (shipping?.status != 'arrived') return ClearanceScreenState.notAvailable;
  if (duty == null) return ClearanceScreenState.choicePending;
  if (duty.handledBy == 'agent') return ClearanceScreenState.agentManaged;
  return ClearanceScreenState.selfCleared;
});

final clearanceServiceFeeProvider = FutureProvider<double>((ref) {
  return ref.watch(clearanceDataSourceProvider).getClearanceServiceFeeGhs();
});

final selectedClearanceOptionProvider =
    StateProvider.family<ClearanceOption?, String>((ref, orderId) => null);

/// First name of the agent assigned to this order (for copy like "Ask Kofi").
final agentFirstNameProvider =
    FutureProvider.family<String, String>((ref, orderId) async {
  final order = await ref.watch(orderProvider(orderId).future);
  final agentId = order?.agentId;
  if (agentId == null || agentId.isEmpty) return 'Your agent';
  final agent = await ref.watch(agentDetailProvider(agentId).future);
  final fullName = agent?.fullName ?? 'Your agent';
  final parts = fullName.trim().split(RegExp(r'\s+'));
  final first = parts.isEmpty ? fullName : parts.first;
  return first.isEmpty ? 'Your agent' : first;
});
