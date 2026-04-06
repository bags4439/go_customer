import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/guide_keys.dart';
import '../../data/datasources/guide_local_datasource.dart';
import '../../data/repositories/guide_repository_impl.dart';
import '../../domain/repositories/guide_repository.dart';
import '../../domain/usecases/has_seen_guide_usecase.dart';
import '../../domain/usecases/mark_guide_seen_usecase.dart';
import '../../domain/usecases/reset_guide_usecase.dart';

// ── Infrastructure ───────────────────────────────

final guideLocalDataSourceProvider =
    Provider<GuideLocalDataSource>((ref) {
  return const GuideLocalDataSource();
});

final guideRepositoryProvider = Provider<GuideRepository>((ref) {
  return GuideRepositoryImpl(
    ref.watch(guideLocalDataSourceProvider),
  );
});

// ── Use case providers ───────────────────────────

final hasSeenGuideUseCaseProvider =
    Provider<HasSeenGuideUseCase>((ref) {
  return HasSeenGuideUseCase(
    ref.watch(guideRepositoryProvider),
  );
});

final markGuideSeenUseCaseProvider =
    Provider<MarkGuideSeenUseCase>((ref) {
  return MarkGuideSeenUseCase(
    ref.watch(guideRepositoryProvider),
  );
});

final resetGuideUseCaseProvider = Provider<ResetGuideUseCase>((ref) {
  return ResetGuideUseCase(
    ref.watch(guideRepositoryProvider),
  );
});

// ── Derived providers ────────────────────────────

/// Whether a specific guide touchpoint has been
/// seen. autoDispose so it re-checks on every
/// screen mount without stale state.
/// Defaults to true (hidden) while loading to
/// avoid flash of guide on fast devices.
final hasSeenGuideProvider = FutureProvider.autoDispose
    .family<bool, String>((ref, key) async {
  final result =
      await ref.watch(hasSeenGuideUseCaseProvider).call(key);
  return result.fold((_) => true, (seen) => seen);
});

/// Notifier that handles marking guides as seen
/// and resetting. Exposes simple async methods
/// to the presentation layer.
class GuideNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> markSeen(String key) async {
    await ref.read(markGuideSeenUseCaseProvider).call(key);
    ref.invalidate(hasSeenGuideProvider(key));
  }

  Future<void> resetAll() async {
    await ref.read(resetGuideUseCaseProvider).call();
    for (final key in GuideKeys.all) {
      ref.invalidate(hasSeenGuideProvider(key));
    }
  }
}

final guideNotifierProvider =
    NotifierProvider<GuideNotifier, void>(GuideNotifier.new);
