import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/providers/firebase_providers.dart';
import '../../data/datasources/vehicle_option_firestore_data_source.dart';
import '../../data/repositories/vehicle_option_repository_impl.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../../orders/presentation/providers/order_timeline_providers.dart';
import '../../domain/entities/buyer_vehicle_response.dart';
import '../../domain/entities/vehicle_option.dart';
import '../../domain/repositories/vehicle_option_repository.dart';
import '../utils/order_searching_step.dart';
import '../../domain/usecases/respond_to_vehicle_option_use_case.dart';
import '../../domain/usecases/watch_order_vehicle_options_use_case.dart';
import '../../domain/usecases/watch_vehicle_option_use_case.dart';

final vehicleOptionFunctionsProvider = Provider<FirebaseFunctions>((ref) {
  return FirebaseFunctions.instanceFor(region: 'europe-west1');
});

final vehicleOptionFirestoreDataSourceProvider =
    Provider<VehicleOptionFirestoreDataSource>((ref) {
  return VehicleOptionFirestoreDataSource(ref.watch(firestoreProvider));
});

final vehicleOptionRepositoryProvider = Provider<VehicleOptionRepository>((ref) {
  return VehicleOptionRepositoryImpl(
    ref.watch(vehicleOptionFirestoreDataSourceProvider),
    ref.watch(vehicleOptionFunctionsProvider),
  );
});

final watchOrderVehicleOptionsUseCaseProvider =
    Provider<WatchOrderVehicleOptionsUseCase>((ref) {
  return WatchOrderVehicleOptionsUseCase(
    ref.watch(vehicleOptionRepositoryProvider),
  );
});

final watchVehicleOptionUseCaseProvider =
    Provider<WatchVehicleOptionUseCase>((ref) {
  return WatchVehicleOptionUseCase(ref.watch(vehicleOptionRepositoryProvider));
});

final respondToVehicleOptionUseCaseProvider =
    Provider<RespondToVehicleOptionUseCase>((ref) {
  return RespondToVehicleOptionUseCase(
    ref.watch(vehicleOptionRepositoryProvider),
  );
});

/// Live list of sent vehicle options for an order.
final orderVehicleOptionsProvider =
    StreamProvider.family<List<VehicleOption>, String>((ref, orderId) {
  final useCase = ref.watch(watchOrderVehicleOptionsUseCaseProvider);
  return useCase(orderId).map(
    (either) => either.fold((_) => <VehicleOption>[], (options) => options),
  );
});

/// Whether the agent has shared at least one listing on this order.
final orderHasVehicleOptionsProvider = Provider.family<bool, String>((
  ref,
  orderId,
) {
  final options = ref.watch(orderVehicleOptionsProvider(orderId)).valueOrNull;
  return options != null && options.isNotEmpty;
});

/// Whether the order's active timeline step is [searching].
final isOrderOnSearchingStepProvider = Provider.family<bool, String>((
  ref,
  orderId,
) {
  final order = ref.watch(orderProvider(orderId)).valueOrNull;
  final timeline = ref.watch(orderTimelineProvider(orderId)).valueOrNull;
  return isOrderOnSearchingStep(order: order, timeline: timeline);
});

/// Sent listings still awaiting buyer feedback (searching step only).
final pendingVehicleFeedbackCountProvider = Provider.family<int, String>((
  ref,
  orderId,
) {
  if (!ref.watch(isOrderOnSearchingStepProvider(orderId))) return 0;
  final options = ref.watch(orderVehicleOptionsProvider(orderId)).valueOrNull;
  if (options == null) return 0;
  return options
      .where((o) => o.buyerResponse == BuyerVehicleResponse.pending)
      .length;
});

/// Total unresponded listings across all active searching-step orders.
final pendingVehicleFeedbackTotalProvider = Provider<int>((ref) {
  final orders = ref.watch(buyerOrdersProvider).valueOrNull ?? [];
  var total = 0;
  for (final order in orders) {
    if (order.isCompleted || order.isCancelled) continue;
    total += ref.watch(pendingVehicleFeedbackCountProvider(order.id));
  }
  return total;
});

/// Options for list UI: pending first, then most recently sent.
List<VehicleOption> sortVehicleOptionsForList(List<VehicleOption> options) {
  final copy = [...options];
  copy.sort((a, b) {
    final aPending = a.buyerResponse == BuyerVehicleResponse.pending;
    final bPending = b.buyerResponse == BuyerVehicleResponse.pending;
    if (aPending != bPending) return aPending ? -1 : 1;
    final aDate = a.sentAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final bDate = b.sentAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return bDate.compareTo(aDate);
  });
  return copy;
}

/// Live single vehicle option (detail screen, chat card).
final vehicleOptionStreamProvider =
    StreamProvider.family<VehicleOption?, String>((ref, vehicleOptionId) {
  final useCase = ref.watch(watchVehicleOptionUseCaseProvider);
  return useCase(vehicleOptionId).map(
    (either) => either.fold((_) => null, (option) => option),
  );
});

/// Agent display info for a vehicle option card.
class AgentForVehicleView {
  const AgentForVehicleView({
    required this.agentId,
    required this.fullName,
    this.photoUrl,
  });

  final String agentId;
  final String fullName;
  final String? photoUrl;

  String get firstName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? fullName : parts.first;
  }

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'AG';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}

final agentForVehicleProvider =
    FutureProvider.family<AgentForVehicleView?, String>((
  ref,
  vehicleOptionId,
) async {
  final option =
      ref.watch(vehicleOptionStreamProvider(vehicleOptionId)).valueOrNull;
  final agentId = option?.agentId;
  if (agentId == null || agentId.isEmpty) return null;

  final firestore = ref.watch(firestoreProvider);
  final agentDoc =
      await firestore.collection(FirestoreCollections.agents).doc(agentId).get();
  if (!agentDoc.exists) return null;

  final userId = agentDoc.data()?['userId'] as String?;
  if (userId == null || userId.isEmpty) {
    return const AgentForVehicleView(agentId: '', fullName: 'Your agent');
  }

  final userDoc =
      await firestore.collection(FirestoreCollections.users).doc(userId).get();
  final fullName = userDoc.data()?['fullName'] as String? ?? 'Your agent';
  final photoUrl = agentDoc.data()?['photoUrl'] as String?;
  return AgentForVehicleView(
    agentId: agentId,
    fullName: fullName,
    photoUrl: photoUrl,
  );
});
