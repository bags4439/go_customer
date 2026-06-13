import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/layout/app_breakpoints.dart';
import 'package:go_customer/core/models/currency_model.dart';
import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';
import 'package:go_customer/core/widgets/styled_snackbar.dart';

import '../../../../shared/providers/currencies_provider.dart';
import '../../../../shared/providers/exchange_rate_provider.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/domain/entities/country.dart';
import '../../../auth/presentation/providers/countries_providers.dart';
import '../../../auth/presentation/widgets/country_picker_sheet.dart';
import '../../core/constants/profile_constants.dart';
import '../providers/profile_providers.dart';
import 'profile_section_shell.dart';

class ProfileLanguageCurrencySection extends ConsumerWidget {
  const ProfileLanguageCurrencySection({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ProfileLanguageRow(currentLanguage: user.preferredLanguage),
        const ProfileSectionDivider(),
        ProfileCurrencyRow(
          currentCurrency: user.preferredCurrency,
          userId: user.id,
        ),
      ],
    );
  }
}

class ProfileLanguageRow extends StatelessWidget {
  const ProfileLanguageRow({
    super.key,
    required this.currentLanguage,
    this.scaleForWebPanel = false,
  });

  final String currentLanguage;
  final bool scaleForWebPanel;

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.sizeOf(context).width;
    final rowStyle = scaleForWebPanel
        ? AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            fontSize: AppBreakpoints.scaledFontSize(13, sw),
          )
        : AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          );
    final valueStyle = scaleForWebPanel
        ? AppTextStyles.bodySmall.copyWith(
            color: Colors.black54,
            fontSize: AppBreakpoints.scaledFontSize(13, sw),
          )
        : AppTextStyles.bodySmall.copyWith(color: Colors.black54);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (ctx) => Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ProfileConstants.languageLabel,
                    style: AppTextStyles.titleSmall.copyWith(fontSize: 16),
                  ),
                  ListTile(
                    title: Text(
                      ProfileConstants.languageEnglish,
                      style: AppTextStyles.bodyMedium,
                    ),
                    onTap: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
          );
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(ProfileConstants.languageLabel, style: rowStyle),
              ),
              Text(ProfileConstants.languageEnglish, style: valueStyle),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileCurrencyRow extends ConsumerWidget {
  const ProfileCurrencyRow({
    super.key,
    required this.currentCurrency,
    required this.userId,
    this.scaleForWebPanel = false,
  });

  final String currentCurrency;
  final String userId;
  final bool scaleForWebPanel;

  static String _currencyLabel(String code, List<CurrencyModel>? currencies) {
    if (currencies == null) return code;
    for (final c in currencies) {
      if (c.code == code) {
        return '${c.symbol}  ${c.name}';
      }
    }
    return code;
  }

  Future<void> _openPicker(
    BuildContext context,
    WidgetRef ref,
    List<CurrencyModel> currencies,
  ) async {
    if (currencies.isEmpty) return;

    final selected = await showModalBottomSheet<CurrencyModel>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ProfileCurrencyPickerSheet(
        currencies: currencies,
        selectedCode: currentCurrency,
      ),
    );

    if (selected == null) return;
    if (!context.mounted) return;

    final result = await ref
        .read(profileRepositoryProvider)
        .updatePreferredCurrency(userId, selected.code);

    result.fold(
      (_) => showErrorSnackBar(
        context,
        ProfileConstants.errorSaveField,
        actionLabel: ProfileConstants.retry,
      ),
      (_) {
        ref.invalidate(currentUserProfileProvider);
        ref.invalidate(exchangeRateProvider);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currenciesAsync = ref.watch(currenciesProvider);
    final list = currenciesAsync.valueOrNull ?? const <CurrencyModel>[];
    final sw = MediaQuery.sizeOf(context).width;
    final labelStyle = scaleForWebPanel
        ? AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            fontSize: AppBreakpoints.scaledFontSize(13, sw),
          )
        : AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          );
    final subStyle = scaleForWebPanel
        ? AppTextStyles.bodySmall.copyWith(
            color: Colors.black54,
            fontSize: AppBreakpoints.scaledFontSize(13, sw),
          )
        : AppTextStyles.bodySmall.copyWith(color: Colors.black54);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openPicker(context, ref, list),
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ProfileConstants.displayCurrencyLabel,
                      style: labelStyle,
                    ),
                    Text(
                      _currencyLabel(
                        currentCurrency,
                        currenciesAsync.valueOrNull,
                      ),
                      style: subStyle,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.edit_outlined,
                size: 20,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCurrencyPickerSheet extends StatelessWidget {
  const _ProfileCurrencyPickerSheet({
    required this.currencies,
    required this.selectedCode,
  });

  final List<CurrencyModel> currencies;
  final String selectedCode;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final maxH = MediaQuery.sizeOf(context).height * 0.75;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: maxH,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Center(
                  child: Container(
                    width: 32,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.borderSolid,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.currency_exchange_rounded,
                        color: AppColors.secondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Display currency',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Prices will display in this currency.',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(
                height: 1,
                thickness: 0.5,
                color: AppColors.borderSolid,
              ),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 24 + bottomInset),
                  itemCount: currencies.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    thickness: 0.5,
                    color: AppColors.borderSolid,
                  ),
                  itemBuilder: (context, i) {
                    final currency = currencies[i];
                    final isSelected = currency.code == selectedCode;
                    return Material(
                      color: isSelected
                          ? AppColors.selectionTint
                          : Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context, currency),
                        splashColor: AppColors.secondary.withValues(
                          alpha: 0.08,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 4,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  currency.symbol,
                                  style: AppTextStyles.titleSmall.copyWith(
                                    fontSize: 16,
                                    color: isSelected
                                        ? AppColors.secondary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currency.name,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? AppColors.secondary
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      currency.code,
                                      style: AppTextStyles.cardLabel,
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: AppColors.secondary,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileCountryRow extends ConsumerWidget {
  const ProfileCountryRow({
    super.key,
    required this.currentIsoCode,
    required this.userId,
  });

  final String currentIsoCode;
  final String userId;

  Country? _currentCountry(List<Country>? countries) {
    if (countries == null) return null;
    for (final c in countries) {
      if (c.isoCode == currentIsoCode) return c;
    }
    return null;
  }

  Future<void> _openPicker(BuildContext context, WidgetRef ref) async {
    final selected = await CountryPickerSheet.show(
      context,
      selectedIsoCode: currentIsoCode,
    );

    if (selected == null) return;
    if (!context.mounted) return;

    final result = await ref
        .read(profileRepositoryProvider)
        .updateCountry(userId, selected.isoCode);

    result.fold(
      (_) => showErrorSnackBar(
        context,
        ProfileConstants.errorSaveField,
        actionLabel: ProfileConstants.retry,
      ),
      (_) {
        ref.invalidate(currentUserProfileProvider);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(countriesProvider);
    final currentCountry = _currentCountry(countriesAsync.valueOrNull);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openPicker(context, ref),
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Country',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      currentCountry != null
                          ? currentCountry.displayLabel
                          : currentIsoCode.isNotEmpty
                          ? currentIsoCode
                          : 'Not set',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.edit_outlined,
                size: 20,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
