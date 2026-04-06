import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/currency_model.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import 'currencies_provider.dart';

/// Returns the [CurrencyModel] for the current
/// user's preferredCurrency setting.
///
/// Falls back to USD if:
/// - user not loaded yet
/// - preferred currency not in active currencies
/// - currencies not loaded yet
///
/// autoDispose so it re-evaluates when user
/// profile changes (e.g. after currency update
/// in profile screen).
final preferredCurrencyProvider =
    Provider.autoDispose<CurrencyModel>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final currenciesAsync = ref.watch(currenciesProvider);

  final preferredCode =
      userAsync.valueOrNull?.preferredCurrency ?? 'USD';
  final currencies = currenciesAsync.valueOrNull ?? [];

  for (final currency in currencies) {
    if (currency.code == preferredCode) {
      return currency;
    }
  }

  if (preferredCode == 'GHS') {
    return const CurrencyModel(
      code: 'GHS',
      symbol: 'GHS',
      name: 'Ghanaian Cedi',
      usdToRate: 15.40,
      decimalDigits: 0,
    );
  }

  return CurrencyModel.usd;
});
