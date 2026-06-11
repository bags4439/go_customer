import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/widgets/card_container.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/providers/exchange_rate_provider.dart';
import '../../../catalogue/domain/entities/car_model.dart';
import '../../../catalogue/presentation/providers/car_catalogue_providers.dart';
import '../../core/preference_catalogue_utils.dart';
import '../../domain/china_import_mode.dart';
import '../providers/preference_form_provider.dart';
import 'preferences_widgets.dart';

const _years = <int>[
  2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019,
  2020, 2021, 2022, 2023, 2024, 2025,
];

/// Step 1 — car selection (car-first funnel).
class PreferenceStepCar extends ConsumerWidget {
  const PreferenceStepCar({super.key, this.budgetFieldKey});

  final GlobalKey<BudgetFieldState>? budgetFieldKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PreferenceStepScrollView(
      child: PreferencesResponsiveColumn(
        children: [
          const SizedBox(height: 4),
          const _CarStepHeader(),
          const SizedBox(height: 24),
          const _ImportTypeSectionWidget(),
          const SizedBox(height: 20),
          const _PopularQuickPicksSection(),
          const _MakeModelRow(),
          const _TrimSectionWidget(),
          const _YearSectionSlot(),
          const _ConditionSectionSlot(),
          BudgetField(key: budgetFieldKey),
          const _AdvancedSourcingSlot(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _CarStepHeader extends StatelessWidget {
  const _CarStepHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'What car do you want?',
          style: GoogleFonts.dmSans(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tell us the car — your agent handles sourcing, shipping, and clearance.',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _ImportTypeSectionWidget extends ConsumerWidget {
  const _ImportTypeSectionWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(
      preferenceFormProvider.select((s) => s.chinaImportMode),
    );
    final notifier = ref.read(preferenceFormProvider.notifier);
    return _ImportTypeSection(chinaImportMode: mode, notifier: notifier);
  }
}

class _PopularQuickPicksSection extends ConsumerWidget {
  const _PopularQuickPicksSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(
      preferenceFormProvider.select(
        (s) => (s.makeSlug, s.modelSlug),
      ),
    );
    final quickPicks = ref.watch(popularQuickPicksProvider);
    final notifier = ref.read(preferenceFormProvider.notifier);

    return quickPicks.when(
      data: (picks) {
        if (picks.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PreferenceSectionLabel('POPULAR'),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: picks.map((p) {
                  final selected = selection.$1 == p.make.slug &&
                      selection.$2 == p.model.slug;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _QuickPickChip(
                      label: '${p.make.name} ${p.model.name}',
                      selected: selected,
                      onTap: () => notifier.applyQuickPick(p.make, p.model),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 22),
          ],
        );
      },
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          PreferenceSectionLabel('POPULAR'),
          SizedBox(height: 10),
          PreferencesChipRowShimmer(),
          SizedBox(height: 22),
        ],
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _MakeModelRow extends ConsumerWidget {
  const _MakeModelRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fields = ref.watch(
      preferenceFormProvider.select(
        (s) => (
          s.chinaImportMode,
          s.make,
          s.model,
          s.makeSlug,
        ),
      ),
    );
    final notifier = ref.read(preferenceFormProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PreferenceSectionLabel('MAKE & MODEL'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: CatalogueSelectorField(
                label: fields.$2.isEmpty ? 'Make' : fields.$2,
                isPlaceholder: fields.$2.isEmpty,
                onTap: () => showCarMakePickerSheet(
                  context: context,
                  importMode: fields.$1,
                  onSelected: (make) {
                    final allowed =
                        isMakeAllowedForImportMode(make, fields.$1);
                    if (!allowed) return;
                    notifier.applyCatalogueMake(make, allowed: true);
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CatalogueSelectorField(
                label: fields.$3.isEmpty ? 'Model' : fields.$3,
                isPlaceholder: fields.$3.isEmpty,
                isEnabled: fields.$2.isNotEmpty,
                onTap: () {
                  final slug = fields.$4;
                  if (slug == null || slug.isEmpty) return;
                  showCarModelPickerSheet(
                    context: context,
                    makeSlug: slug,
                    onSelected: (model) =>
                        notifier.applyCatalogueModel(model),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TrimSectionWidget extends ConsumerWidget {
  const _TrimSectionWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trimState = ref.watch(
      preferenceFormProvider.select(
        (s) => (
          s.makeSlug,
          s.modelSlug,
          s.model,
          s.trim,
          s.isNewVehicle,
        ),
      ),
    );
    final notifier = ref.read(preferenceFormProvider.notifier);
    return _TrimSection(
      makeSlug: trimState.$1,
      modelSlug: trimState.$2,
      model: trimState.$3,
      trim: trimState.$4,
      isNewVehicle: trimState.$5,
      notifier: notifier,
    );
  }
}

class _YearSectionSlot extends ConsumerWidget {
  const _YearSectionSlot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNewVehicle = ref.watch(
      preferenceFormProvider.select((s) => s.isNewVehicle),
    );
    if (isNewVehicle) return const SizedBox.shrink();

    final yearState = ref.watch(
      preferenceFormProvider.select(
        (s) => (
          s.yearRangeExpanded,
          s.yearFrom,
          s.yearMin,
          s.yearMax,
          s.isSingleYear,
        ),
      ),
    );
    final notifier = ref.read(preferenceFormProvider.notifier);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: _YearSection(
        yearRangeExpanded: yearState.$1,
        yearFrom: yearState.$2,
        yearMin: yearState.$3,
        yearMax: yearState.$4,
        isSingleYear: yearState.$5,
        notifier: notifier,
      ),
    );
  }
}

class _ConditionSectionSlot extends ConsumerWidget {
  const _ConditionSectionSlot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(
      preferenceFormProvider.select(
        (s) => (s.isNewVehicle, s.isChinaUsed, s.condition),
      ),
    );
    if (mode.$1) return const SizedBox.shrink();

    final notifier = ref.read(preferenceFormProvider.notifier);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PreferenceSectionLabel('CONDITION'),
          const SizedBox(height: 10),
          if (mode.$2)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: PreferenceCompactConditionCard(
                    icon: Icons.thumb_up_outlined,
                    iconColor: AppColors.success,
                    title: 'Good condition',
                    subtitle: 'Low mileage, no significant damage.',
                    selected:
                        mode.$3 == PreferenceCondition.goodCondition,
                    onTap: () => notifier.updateCondition(
                      PreferenceCondition.goodCondition,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PreferenceCompactConditionCard(
                    icon: Icons.thumbs_up_down_outlined,
                    iconColor: AppColors.warning,
                    title: 'Fair condition',
                    subtitle: 'Moderate use, acceptable wear.',
                    selected: mode.$3 == PreferenceCondition.fairCondition,
                    onTap: () => notifier.updateCondition(
                      PreferenceCondition.fairCondition,
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: PreferenceCompactConditionCard(
                    icon: Icons.check_circle_outline,
                    iconColor: AppColors.success,
                    title: 'Ready to use',
                    subtitle: 'Minor cosmetic damage only. Best value.',
                    badge: 'Most popular',
                    badgeBackground: AppColors.successMutedBackground,
                    badgeTextColor: AppColors.successMutedForeground,
                    selected:
                        mode.$3 == PreferenceCondition.readyToDrive,
                    onTap: () => notifier.updateCondition(
                      PreferenceCondition.readyToDrive,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PreferenceCompactConditionCard(
                    icon: Icons.build_outlined,
                    iconColor: AppColors.warning,
                    title: 'Needs some work',
                    subtitle: 'Body or mechanical damage. Lower price.',
                    badge: 'Lower price',
                    badgeBackground: AppColors.amberBackground,
                    badgeTextColor: AppColors.amberText,
                    selected: mode.$3 ==
                        PreferenceCondition.needsModerateRepair,
                    onTap: () => notifier.updateCondition(
                      PreferenceCondition.needsModerateRepair,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _AdvancedSourcingSlot extends ConsumerWidget {
  const _AdvancedSourcingSlot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUsedImport = ref.watch(
      preferenceFormProvider.select((s) => s.isUsedImport),
    );
    if (!isUsedImport) return const SizedBox.shrink();

    final advanced = ref.watch(
      preferenceFormProvider.select(
        (s) => (s.showAdvancedSourcing, s.advancedPurchaseOrigin),
      ),
    );
    final notifier = ref.read(preferenceFormProvider.notifier);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: _AdvancedSourcingSection(
        showAdvancedSourcing: advanced.$1,
        advancedPurchaseOrigin: advanced.$2,
        notifier: notifier,
      ),
    );
  }
}

class PreferenceStepReview extends ConsumerWidget {
  const PreferenceStepReview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(preferenceFormProvider);
    final notifier = ref.read(preferenceFormProvider.notifier);
    final budgetUsd = state.maxBudgetUsd;
    final budgetFitAsync = ref.watch(budgetFitAssessmentProvider);

    return PreferenceStepScrollView(
      child: PreferencesResponsiveColumn(
        children: [
          const SizedBox(height: 4),
          Text(
            'Review your request',
            style: GoogleFonts.dmSans(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check everything looks right before we find your agent.',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          _ReviewCarCard(state: state, notifier: notifier),
          const SizedBox(height: 12),
          if (!state.isNewVehicle || budgetUsd != null)
            CardContainer(
              paddingType: CardContainerPaddingType.large,
              child: Column(
                children: [
                  if (!state.isNewVehicle)
                    ReviewKeyValueRow(
                      label: 'Condition',
                      value: preferenceConditionUiLabel(state.condition),
                      onEdit: () => notifier.goToStep(1),
                    ),
                  if (budgetUsd != null)
                    ReviewKeyValueRow(
                      label: 'Budget',
                      value: CurrencyFormatter.formatUsd(budgetUsd.toDouble()),
                      onEdit: () => notifier.goToStep(1),
                    ),
                ],
              ),
            ),
          if (state.isNewVehicle) ...[
            const SizedBox(height: 12),
            _newVehicleAgentNote(),
          ],
          if (budgetUsd != null && !state.isNewVehicle) ...[
            const SizedBox(height: 16),
            budgetFitAsync.when(
              data: (fit) {
                if (fit == null) return const SizedBox.shrink();
                return BudgetFitSpectrumCard(assessment: fit);
              },
              loading: () => const BudgetFitSpectrumCardShimmer(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
          const SizedBox(height: 20),
          _WhatHappensNextCard(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _newVehicleAgentNote() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.infoBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.info_outline,
              size: 16,
              color: AppColors.infoText,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your agent will provide a detailed quote based on your requirements.',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.infoText,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImportTypeSection extends StatelessWidget {
  const _ImportTypeSection({
    required this.chinaImportMode,
    required this.notifier,
  });

  final ChinaImportMode chinaImportMode;
  final PreferenceFormNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PreferenceSectionLabel('IMPORT TYPE'),
        const SizedBox(height: 10),
        _ImportChip(
          label: 'Used import',
          subtitle: 'US auctions, Dubai & more — agent finds the best source',
          selected: chinaImportMode == ChinaImportMode.none,
          onTap: () => _setMode(ChinaImportMode.none),
        ),
        const SizedBox(height: 8),
        _ImportChip(
          label: 'Brand new from China',
          subtitle: 'Factory-new vehicle sourced directly from China',
          selected: chinaImportMode == ChinaImportMode.newFromChina,
          onTap: () => _setMode(ChinaImportMode.newFromChina),
        ),
        const SizedBox(height: 8),
        _ImportChip(
          label: 'Used from China',
          subtitle: 'Pre-owned vehicle imported from China',
          selected: chinaImportMode == ChinaImportMode.usedFromChina,
          onTap: () => _setMode(ChinaImportMode.usedFromChina),
        ),
      ],
    );
  }

  void _setMode(ChinaImportMode mode) {
    if (mode == chinaImportMode) return;
    notifier.updateChinaImportMode(mode);
    notifier.clearVehicleSelection();
  }
}

class _ImportChip extends StatelessWidget {
  const _ImportChip({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected ? AppColors.selectionTint : AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? AppColors.secondary : AppColors.borderSolid,
          width: selected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: selected ? 14 : 8,
            color: selected
                ? AppColors.secondary.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.secondary.withValues(alpha: 0.12)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    selected ? Icons.check_rounded : Icons.circle_outlined,
                    color: selected
                        ? AppColors.secondary
                        : AppColors.textTertiary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdvancedSourcingSection extends StatelessWidget {
  const _AdvancedSourcingSection({
    required this.showAdvancedSourcing,
    required this.advancedPurchaseOrigin,
    required this.notifier,
  });

  final bool showAdvancedSourcing;
  final String advancedPurchaseOrigin;
  final PreferenceFormNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: notifier.toggleAdvancedSourcing,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Advanced sourcing preference',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    showAdvancedSourcing
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 20,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showAdvancedSourcing) ...[
          const SizedBox(height: 4),
          for (final entry in <(String, String, String)>[
            (
              AppConstants.purchaseOriginAny,
              'No preference',
              'Agent finds the best source',
            ),
            (
              AppConstants.purchaseOriginUsCanada,
              'US / Canada',
              'Auction vehicles (Copart / IAA)',
            ),
            (
              AppConstants.purchaseOriginDubai,
              'Dubai / Middle East',
              'Typically used, low mileage',
            ),
          ]) ...[
            SelectablePreferenceTile(
              title: entry.$2,
              subtitle: entry.$3,
              selected: advancedPurchaseOrigin == entry.$1,
              onTap: () => notifier.updateAdvancedPurchaseOrigin(entry.$1),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }
}

class _QuickPickChip extends StatelessWidget {
  const _QuickPickChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.infoBackground : AppColors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.secondary : AppColors.borderSolid,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      blurRadius: 8,
                      color: AppColors.secondary.withValues(alpha: 0.08),
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: selected ? AppColors.infoText : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _YearSection extends StatelessWidget {
  const _YearSection({
    required this.yearRangeExpanded,
    required this.yearFrom,
    required this.yearMin,
    required this.yearMax,
    required this.isSingleYear,
    required this.notifier,
  });

  final bool yearRangeExpanded;
  final int yearFrom;
  final int yearMin;
  final int yearMax;
  final bool isSingleYear;
  final PreferenceFormNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final yearsTo = _years.where((y) => y >= yearFrom).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const PreferenceSectionLabel('YEAR'),
            const Spacer(),
            TextButton(
              onPressed: () =>
                  notifier.setYearRangeExpanded(!yearRangeExpanded),
              style: TextButton.styleFrom(
                minimumSize: const Size(48, 36),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Text(
                yearRangeExpanded ? 'Single year' : 'Flexible on year',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 76,
          child: yearRangeExpanded
              ? Row(
                  children: [
                    Expanded(
                      child: YearSelectorField(
                        heading: 'From',
                        value: yearMin,
                        years: _years,
                        onChanged: notifier.updateYearFrom,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: YearSelectorField(
                        heading: 'To',
                        value: yearMax,
                        years: yearsTo,
                        onChanged: notifier.updateYearTo,
                      ),
                    ),
                  ],
                )
              : YearSelectorField(
                  heading: 'Year',
                  value: yearFrom,
                  years: _years,
                  showHeading: false,
                  onChanged: notifier.updateYearFrom,
                ),
        ),
        const SizedBox(height: 6),
        Text(
          isSingleYear
              ? 'Exact year — estimates will be more precise'
              : 'Year range — estimates may show a range',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.infoText,
          ),
        ),
      ],
    );
  }
}

/// USD budget input — local text state; commits to provider on blur/dispose.
class BudgetField extends ConsumerStatefulWidget {
  const BudgetField({super.key});

  @override
  ConsumerState<BudgetField> createState() => BudgetFieldState();
}

class BudgetFieldState extends ConsumerState<BudgetField> {
  late final TextEditingController _ctrl;
  late final FocusNode _focusNode;
  String _localText = '';

  @override
  void initState() {
    super.initState();
    final committed = ref.read(preferenceFormProvider).maxBudgetUsd;
    final initial = committed != null ? '$committed' : '';
    _localText = initial;
    _ctrl = TextEditingController(text: initial);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) commit();
  }

  int? _parseUsd(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    final v = int.tryParse(digits);
    if (v == null || v <= 0) return null;
    return v;
  }

  void commit() {
    ref.read(preferenceFormProvider.notifier).commitMaxBudgetUsd(
          _parseUsd(_localText),
        );
  }

  @override
  void dispose() {
    commit();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final importMode = ref.watch(
      preferenceFormProvider.select((s) => s.chinaImportMode),
    );
    final copy = PreferenceBudgetCopy.forImportMode(importMode);
    final rate = ref.watch(exchangeRateProvider).valueOrNull?.usdToGhs ?? 0;
    final parsed = _parseUsd(_localText);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PreferenceSectionLabel('MAX BUDGET (OPTIONAL)'),
          const SizedBox(height: 10),
          TextField(
            controller: _ctrl,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            scrollPadding: const EdgeInsets.only(bottom: 140),
            onChanged: (v) => setState(() => _localText = v),
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: copy.hint,
              hintStyle: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
              prefixText: r'$ ',
              filled: true,
              fillColor: AppColors.background,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderSolid),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderSolid),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.secondary, width: 1.5),
              ),
            ),
          ),
          if (parsed != null && rate > 0) ...[
            const SizedBox(height: 6),
            Text(
              '≈ ${CurrencyFormatter.formatGhs(parsed * rate)}',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
              ),
            ),
            Text(
              '1 USD = ${rate.toStringAsFixed(2)} GHS',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            copy.helper,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: AppColors.textTertiary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrimSection extends ConsumerWidget {
  const _TrimSection({
    required this.makeSlug,
    required this.modelSlug,
    required this.model,
    required this.trim,
    required this.isNewVehicle,
    required this.notifier,
  });

  final String? makeSlug;
  final String? modelSlug;
  final String model;
  final String? trim;
  final bool isNewVehicle;
  final PreferenceFormNotifier notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slug = makeSlug;
    if (slug == null || slug.isEmpty || model.isEmpty || isNewVehicle) {
      return const SizedBox.shrink();
    }

    final modelsAsync = ref.watch(carModelsProvider(slug));

    return modelsAsync.when(
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          SizedBox(height: 16),
          PreferenceSectionLabel('TRIM (OPTIONAL)'),
          SizedBox(height: 10),
          PreferencesChipRowShimmer(),
        ],
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (models) {
        CarModel? selectedModel;
        for (final m in models) {
          if (m.slug == modelSlug) {
            selectedModel = m;
            break;
          }
        }
        final trims = selectedModel?.trims ?? [];
        if (trims.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const PreferenceSectionLabel('TRIM (OPTIONAL)'),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  TrimChip(
                    label: 'Any trim',
                    selected: trim == null,
                    onTap: () => notifier.updateTrim(null),
                  ),
                  ...trims.map(
                    (t) => TrimChip(
                      label: t,
                      selected: trim == t,
                      onTap: () => notifier.updateTrim(t),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ReviewCarCard extends StatelessWidget {
  const _ReviewCarCard({required this.state, required this.notifier});

  final PreferenceFormState state;
  final PreferenceFormNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSolid, width: 0.5),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 4),
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.selectionTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_car_filled_outlined,
              color: AppColors.secondary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${state.make} ${state.model}',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                if (!state.isNewVehicle) ...[
                  const SizedBox(height: 4),
                  Text(
                    state.isSingleYear
                        ? '${state.yearMin}'
                        : '${state.yearMin}–${state.yearMax}',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (state.trim != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Trim: ${state.trim}',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              OriginBadge(purchaseOrigin: state.purchaseOrigin),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => notifier.goToStep(1),
                child: Text(
                  'Edit',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WhatHappensNextCard extends StatelessWidget {
  const _WhatHappensNextCard();

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      paddingType: CardContainerPaddingType.large,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What happens next',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const NextStepRow(
            number: 1,
            text:
                'We match you with a dedicated agent (usually within 30 seconds)',
          ),
          const NextStepRow(
            number: 2,
            text:
                'Your agent searches for your car and sends you options in chat',
          ),
          const NextStepRow(
            number: 3,
            text: 'No payment until your agent sends a payment request',
          ),
        ],
      ),
    );
  }
}
