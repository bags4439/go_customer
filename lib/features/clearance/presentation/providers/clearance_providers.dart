import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/firebase_providers.dart';
import '../../../../shared/providers/system_settings_provider.dart';
import '../../../orders/presentation/providers/order_providers.dart';
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
enum ClearanceOption { agentHandles, selfClearance }

final clearanceDataSourceProvider = Provider<ClearanceFirestoreDataSource>((
  ref,
) {
  return ClearanceFirestoreDataSource(ref.watch(firestoreProvider));
});

final dutyClearanceRepositoryProvider = Provider<DutyClearanceRepository>((
  ref,
) {
  return DutyClearanceRepositoryImpl(
    ref.watch(clearanceDataSourceProvider),
    ref.watch(functionsProvider),
  );
});

final dutyClearanceProvider = StreamProvider.family<DutyClearance?, String>((
  ref,
  orderId,
) {
  return ref.watch(dutyClearanceRepositoryProvider).watchDutyClearance(orderId);
});

final clearanceScreenStateProvider =
    Provider.family<ClearanceScreenState, String>((ref, orderId) {
      final order = ref.watch(orderProvider(orderId)).valueOrNull;
      final duty = ref.watch(dutyClearanceProvider(orderId)).valueOrNull;

      // Clearance is available when the order stage is at or past
      // clearance (stageNumber >= 7). This is driven by orders.stageNumber
      // set by the agent — not by the shipping document status.
      if ((order?.stageNumber ?? 0) < 7) {
        return ClearanceScreenState.notAvailable;
      }
      if (duty == null) return ClearanceScreenState.choicePending;
      if (duty.handledBy == 'agent') return ClearanceScreenState.agentManaged;
      return ClearanceScreenState.selfCleared;
    });

/// Clearance service fee in USD. For display, convert to the user's
/// preferred currency using `CurrencyFormatter.formatForDisplay`.
final clearanceServiceFeeProvider = FutureProvider<double>((ref) async {
  final settings = await ref.watch(systemSettingsProvider.future);
  return ref
      .read(clearanceDataSourceProvider)
      .getClearanceServiceFeeUsd(settings);
});

final selectedClearanceOptionProvider =
    StateProvider.family<ClearanceOption?, String>((ref, orderId) => null);

/// True while the buyer is confirming a clearance choice — keeps choice UI mounted.
final clearanceChoiceSubmittingProvider =
    StateProvider.family<bool, String>((ref, orderId) => false);

/// First name of the agent assigned to this order (for copy like "Ask Kofi").
final agentFirstNameProvider = FutureProvider.family<String, String>((
  ref,
  orderId,
) async {
  final order = await ref.watch(orderProvider(orderId).future);
  final agentId = order?.agentId;
  if (agentId == null || agentId.isEmpty) return 'Your agent';
  final agent = await ref.watch(agentDetailProvider(agentId).future);
  final fullName = agent?.fullName ?? 'Your agent';
  final parts = fullName.trim().split(RegExp(r'\s+'));
  final first = parts.isEmpty ? fullName : parts.first;
  return first.isEmpty ? 'Your agent' : first;
});
