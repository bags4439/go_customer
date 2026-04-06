import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/firebase_providers.dart';
import '../../data/datasources/countries_firestore_datasource.dart';
import '../../data/repositories/countries_repository_impl.dart';
import '../../domain/entities/country.dart';
import '../../domain/repositories/countries_repository.dart';
import '../../domain/usecases/get_countries_usecase.dart';

final countriesDataSourceProvider =
    Provider<CountriesFirestoreDataSource>((ref) {
  return CountriesFirestoreDataSource(
    ref.watch(firestoreProvider),
  );
});

final countriesRepositoryProvider =
    Provider<CountriesRepository>((ref) {
  return CountriesRepositoryImpl(
    ref.watch(countriesDataSourceProvider),
  );
});

final getCountriesUseCaseProvider =
    Provider<GetCountriesUseCase>((ref) {
  return GetCountriesUseCase(
    ref.watch(countriesRepositoryProvider),
  );
});

/// Fetches and caches active countries for the
/// session. Falls back to Ghana + USA if the
/// collection is empty or unreachable.
final countriesProvider =
    FutureProvider<List<Country>>((ref) async {
  final result =
      await ref.watch(getCountriesUseCaseProvider).call();
  return result.fold(
    (_) => _fallbackCountries,
    (countries) =>
        countries.isEmpty ? _fallbackCountries : countries,
  );
});

/// Minimal fallback shown if Firestore is
/// unreachable during registration.
const _fallbackCountries = [
  Country(
    isoCode: 'GH',
    name: 'Ghana',
    flag: '🇬🇭',
    dialCode: '+233',
  ),
  Country(
    isoCode: 'US',
    name: 'United States',
    flag: '🇺🇸',
    dialCode: '+1',
  ),
];
