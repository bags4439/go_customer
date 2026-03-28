import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/firebase_providers.dart';
import '../../../clearance/presentation/providers/clearance_providers.dart';
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
    ref.watch(functionsProvider),
  );
});

final repairJobProvider =
    StreamProvider.family<RepairJob?, String>((ref, orderId) {
  return ref.watch(repairRepositoryProvider).watchRepairJob(orderId);
});

final carPreferencesRepairOptedInProvider =
    FutureProvider.family<bool?, String>((ref, orderId) {
  return ref.watch(repairDataSourceProvider).getCarPreferencesRepairOptedIn(orderId);
});

final repairScreenStateProvider =
    Provider.family<RepairScreenState, String>((ref, orderId) {
  final duty = ref.watch(dutyClearanceProvider(orderId)).valueOrNull;
  final job = ref.watch(repairJobProvider(orderId)).valueOrNull;
  final repairOptedIn = ref.watch(carPreferencesRepairOptedInProvider(orderId)).valueOrNull;

  if (duty?.graStatus != 'cleared') return RepairScreenState.notAvailable;
  if (job == null) return RepairScreenState.choice;
  if (job.isNotStarted && repairOptedIn == false) return RepairScreenState.noRepair;
  if (job.isNotStarted && repairOptedIn == true) return RepairScreenState.awaitingQuote;
  if (job.isQuoteSent) return RepairScreenState.quoteSent;
  if (job.isQuoteDeclined) return RepairScreenState.quoteDeclined;
  if (job.isQuoteApproved || job.isInProgress) return RepairScreenState.inProgress;
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
