import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/firebase_providers.dart';
import '../../../../shared/providers/system_settings_provider.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../../orders/presentation/providers/order_timeline_providers.dart';
import '../../../orders/presentation/utils/timeline_payment_resolver.dart';
import '../../../payments/data/models/payment_request_model.dart';
import '../../data/datasources/repair_firestore_data_source.dart';
import '../../data/repositories/repair_repository_impl.dart';
import '../../domain/entities/garage.dart';
import '../../domain/entities/repair_job.dart';
import '../../domain/repositories/repair_repository.dart';

/// Screen state for repair route: which UI to show.
enum RepairScreenState {
  notAvailable,
  choice,
  awaitingQuote,
  quoteSent,
  quoteDeclined,
  quoteApproved,
  inProgress,
  complete,
  noRepair,
}

final repairDataSourceProvider = Provider<RepairFirestoreDataSource>((ref) {
  return RepairFirestoreDataSource(ref.watch(firestoreProvider));
});

final repairRepositoryProvider = Provider<RepairRepository>((ref) {
  return RepairRepositoryImpl(
    ref.watch(repairDataSourceProvider),
    FirebaseFunctions.instanceFor(region: 'europe-west1'),
  );
});

final repairJobProvider =
    StreamProvider.family<RepairJob?, String>((ref, orderId) {
  return ref.watch(repairRepositoryProvider).watchRepairJob(orderId);
});

final repairScreenStateProvider =
    Provider.family<RepairScreenState, String>((ref, orderId) {
  final order = ref.watch(orderProvider(orderId)).valueOrNull;
  final job = ref.watch(repairJobProvider(orderId)).valueOrNull;

  // Repairs is available when the
  // order stage is at or past
  // repairs (stageNumber >= 8).
  // Driven by orders.stageNumber
  // set by the agent — not by
  // duty_clearance.graStatus.
  if ((order?.stageNumber ?? 0) < 8) return RepairScreenState.notAvailable;
  if (job == null) return RepairScreenState.choice;

  // Use optedIn stored on the job
  // document — no race condition
  // since it is written atomically
  // with the job creation.
  if (job.isNotStarted && !job.optedIn) {
    return RepairScreenState.noRepair;
  }
  if (job.isNotStarted) {
    return RepairScreenState.awaitingQuote;
  }
  // Buyer approved client-side before CF sets status → quote_approved.
  if (job.isQuoteSent && job.quoteApprovedByBuyer == true) {
    return RepairScreenState.quoteApproved;
  }
  if (job.isQuoteSent) return RepairScreenState.quoteSent;
  if (job.isQuoteDeclined) return RepairScreenState.quoteDeclined;
  if (job.isQuoteApproved) return RepairScreenState.quoteApproved;
  if (job.isInProgress) return RepairScreenState.inProgress;
  if (job.isCompleted) return RepairScreenState.complete;
  return RepairScreenState.choice;
});

final repairEstimateProvider =
    FutureProvider.family<double?, String>((ref, orderId) {
  return ref.watch(repairDataSourceProvider).getRepairEstimateFromConfirmedVehicle(orderId);
});

final garageDetailsProvider =
    FutureProvider.family<Garage?, String?>((ref, garageId) {
  if (garageId == null || garageId.isEmpty) return Future.value(null);
  return ref.watch(repairDataSourceProvider).getGarage(garageId);
});

/// true = Option A (arrange repairs), false = Option B (deliver as-is), null = nothing selected.
/// Pre-populate from car_preferences.repairOptedIn when choice screen loads.
final repairChoiceProvider = StateProvider.family<bool?, String>((ref, orderId) => null);

/// True while the buyer is confirming a repair choice — keeps choice UI mounted.
final repairChoiceSubmittingProvider =
    StateProvider.family<bool, String>((ref, orderId) => false);

/// True while the buyer is accepting a repair quote — keeps quote UI mounted.
final repairQuoteAcceptSubmittingProvider =
    StateProvider.family<bool, String>((ref, orderId) => false);

/// Repair coordination fee in USD.
/// Convert to preferred currency for display using
/// CurrencyFormatter.formatForDisplay.
/// Returns 0.0 if not set in system_settings.
final repairServiceFeeProvider = FutureProvider<double>((ref) async {
  final settings = await ref.watch(systemSettingsProvider.future);
  return ref.read(repairDataSourceProvider).getRepairServiceFeeUsd(settings);
});

/// Pending repair-stage payment (deposit or balance) from the standard
/// payment_requests flow — same resolver as order timeline.
final repairPendingPaymentProvider =
    Provider.family<AsyncValue<PaymentRequestModel?>, String>((ref, orderId) {
  return ref.watch(pendingPaymentRequestsProvider(orderId)).whenData(
        (pending) => resolvePendingPaymentForStage('repair', pending),
      );
});
