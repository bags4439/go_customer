import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/firebase_providers.dart';
import '../../data/datasources/car_catalogue_firestore_data_source.dart';
import '../../data/repositories/car_catalogue_repository_impl.dart';
import '../../domain/entities/car_make.dart';
import '../../domain/entities/car_model.dart';
import '../../domain/repositories/car_catalogue_repository.dart';
import '../../domain/usecases/fetch_car_makes_use_case.dart';
import '../../domain/usecases/fetch_car_models_use_case.dart';

final carCatalogueDataSourceProvider =
    Provider<CarCatalogueFirestoreDataSource>((ref) {
  return CarCatalogueFirestoreDataSource(ref.watch(firestoreProvider));
});

final carCatalogueRepositoryProvider = Provider<CarCatalogueRepository>((ref) {
  return CarCatalogueRepositoryImpl(
    ref.watch(carCatalogueDataSourceProvider),
  );
});

final fetchCarMakesUseCaseProvider = Provider<FetchCarMakesUseCase>((ref) {
  return FetchCarMakesUseCase(ref.watch(carCatalogueRepositoryProvider));
});

final fetchCarModelsUseCaseProvider = Provider<FetchCarModelsUseCase>((ref) {
  return FetchCarModelsUseCase(ref.watch(carCatalogueRepositoryProvider));
});

final carMakesProvider =
    AsyncNotifierProvider<CarMakesNotifier, List<CarMake>>(CarMakesNotifier.new);

class CarMakesNotifier extends AsyncNotifier<List<CarMake>> {
  @override
  Future<List<CarMake>> build() async {
    ref.keepAlive();
    final useCase = ref.watch(fetchCarMakesUseCaseProvider);
    final result = await useCase();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (makes) => makes,
    );
  }
}

final carModelsProvider = AsyncNotifierProvider.family<
    CarModelsNotifier,
    List<CarModel>,
    String>(CarModelsNotifier.new);

class CarModelsNotifier extends FamilyAsyncNotifier<List<CarModel>, String> {
  @override
  Future<List<CarModel>> build(String makeSlug) async {
    ref.keepAlive();
    if (makeSlug.isEmpty) return [];
    final useCase = ref.watch(fetchCarModelsUseCaseProvider);
    final result = await useCase(makeSlug);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (models) => models,
    );
  }
}

final popularMakesProvider = Provider<List<CarMake>>((ref) {
  final makes = ref.watch(carMakesProvider).valueOrNull ?? [];
  return makes.where((m) => m.popular).toList();
});

final allMakesProvider = Provider<List<CarMake>>((ref) {
  return ref.watch(carMakesProvider).valueOrNull ?? [];
});
