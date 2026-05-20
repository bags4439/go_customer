import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/widgets/card_container.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/layout/panel_divider.dart';
import '../../../../core/layout/web_app_body.dart';
import '../../../../core/layout/web_app_shell.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../catalogue/domain/entities/car_model.dart';
import '../../../catalogue/presentation/providers/car_catalogue_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/preference_form_provider.dart';
import '../widgets/preferences_widgets.dart';

int _displayStep(PreferenceFormState s) {
  if (!s.skipConditionStep) return s.currentStep;
  if (s.currentStep <= 2) return s.currentStep;
  return 3;
}

int _totalSteps(PreferenceFormState s) => s.skipConditionStep ? 3 : 4;

class PreferencesNewScreen extends ConsumerStatefulWidget {
  const PreferencesNewScreen({super.key});

  @override
  ConsumerState<PreferencesNewScreen> createState() =>
      _PreferencesNewScreenState();
}

class _PreferencesNewScreenState extends ConsumerState<PreferencesNewScreen> {
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(preferenceFormProvider.notifier).reset();
    });
  }

  Future<void> _onConfirm(
    BuildContext context,
    PreferenceFormState state,
  ) async {
    final router = GoRouter.of(context);
    final uid = ref.read(authStateProvider).value;
    if (uid == null) return;
    setState(() => _submitting = true);
    final result = await ref
        .read(createOrderFromPreferencesUseCaseProvider)
        .call(buyerId: uid, submission: toSubmission(state));
    if (!mounted) return;
    setState(() => _submitting = false);
    result.fold(
      (failure) => showFailureSnackBar(context, failure),
      (orderId) => router.go('/order/$orderId/agent-connection'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(preferenceFormProvider);
    final notifier = ref.read(preferenceFormProvider.notifier);
    final isWeb = AppBreakpoints.isWeb(context);

    final body = SafeArea(
      child: Column(
        children: [
          PreferencesStepProgressBar(
            displayStep: _displayStep(state),
            totalSteps: _totalSteps(state),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0.06, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: KeyedSubtree(
                key: ValueKey<int>(state.currentStep),
                child: _buildStep(context, state, notifier),
              ),
            ),
          ),
          PreferencesBottomNavBar(
            state: state,
            notifier: notifier,
            isLoading: _submitting,
            onConfirm: () => _onConfirm(context, state),
          ),
        ],
      ),
    );

    final scaffold = Scaffold(
      backgroundColor: isWeb ? AppColors.surface : AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () {
            if (state.currentStep == 1) {
              context.pop();
            } else {
              notifier.previousStep();
            }
          },
        ),
        backgroundColor: isWeb ? AppColors.surface : AppColors.background,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 52,
        title: Text(
          'Car preferences',
          style: GoogleFonts.dmSans(
            fontSize: AppBreakpoints.scaledFontSize(
              isWeb ? 15 : 17,
              MediaQuery.sizeOf(context).width,
            ),
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.borderSolid),
        ),
      ),
      body: body,
    );

    if (!isWeb) {
      return PopScope(
        canPop: state.currentStep == 1,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) notifier.previousStep();
        },
        child: scaffold,
      );
    }

    return WebAppBody(body: body, pageTitle: "Car Preferences");
  }

  Widget _buildStep(
    BuildContext context,
    PreferenceFormState state,
    PreferenceFormNotifier notifier,
  ) {
    if (state.currentStep == 1) {
      return _StepPurchaseOrigin(state: state, notifier: notifier);
    }
    if (state.currentStep == 2) {
      return _StepCarSelection(state: state, notifier: notifier);
    }
    if (state.currentStep == 3 && !state.skipConditionStep) {
      return _StepConditionMileage(state: state, notifier: notifier);
    }
    if (state.currentStep == 4) {
      return _StepReview(state: state, notifier: notifier);
    }
    return const SizedBox.expand();
  }
}

class _StepPurchaseOrigin extends StatelessWidget {
  final PreferenceFormState state;
  final PreferenceFormNotifier notifier;

  const _StepPurchaseOrigin({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: PreferencesResponsiveColumn(
        children: [
          const SizedBox(height: 8),
          Text(
            'Where should we source your car from?',
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'This helps your agent know where to look.',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          OriginCard(
            origin: AppConstants.purchaseOriginAny,
            icon: Icons.public_outlined,
            label: AppConstants.purchaseOriginLabels['any']!,
            subtitle: AppConstants.purchaseOriginSubtitles['any']!,
            selected: state.purchaseOrigin == AppConstants.purchaseOriginAny,
            onTap: () =>
                notifier.updatePurchaseOrigin(AppConstants.purchaseOriginAny),
          ),
          const SizedBox(height: 10),
          OriginCard(
            origin: AppConstants.purchaseOriginUsCanada,
            icon: Icons.directions_car_outlined,
            label: AppConstants.purchaseOriginLabels['us_canada']!,
            subtitle: AppConstants.purchaseOriginSubtitles['us_canada']!,
            selected:
                state.purchaseOrigin == AppConstants.purchaseOriginUsCanada,
            onTap: () => notifier.updatePurchaseOrigin(
              AppConstants.purchaseOriginUsCanada,
            ),
          ),
          const SizedBox(height: 10),
          OriginCard(
            origin: AppConstants.purchaseOriginDubai,
            icon: Icons.flight_outlined,
            label: AppConstants.purchaseOriginLabels['dubai']!,
            subtitle: AppConstants.purchaseOriginSubtitles['dubai']!,
            selected: state.purchaseOrigin == AppConstants.purchaseOriginDubai,
            onTap: () =>
                notifier.updatePurchaseOrigin(AppConstants.purchaseOriginDubai),
          ),
          const SizedBox(height: 10),
          OriginCard(
            origin: AppConstants.purchaseOriginChina,
            icon: Icons.electric_car_outlined,
            label: AppConstants.purchaseOriginLabels['china']!,
            subtitle: AppConstants.purchaseOriginSubtitles['china']!,
            selected: state.purchaseOrigin == AppConstants.purchaseOriginChina,
            onTap: () =>
                notifier.updatePurchaseOrigin(AppConstants.purchaseOriginChina),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _StepCarSelection extends ConsumerWidget {
  final PreferenceFormState state;
  final PreferenceFormNotifier notifier;

  const _StepCarSelection({required this.state, required this.notifier});

  static const List<int> _years = [
    2010,
    2011,
    2012,
    2013,
    2014,
    2015,
    2016,
    2017,
    2018,
    2019,
    2020,
    2021,
    2022,
    2023,
    2024,
    2025,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yearsTo = _years.where((y) => y >= state.yearMin).toList();

    return SingleChildScrollView(
      child: PreferencesResponsiveColumn(
        children: [
          const SizedBox(height: 8),
          Text(
            'What car do you want?',
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Don\'t worry if you\'re unsure — your agent will help.',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'MAKE',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          CatalogueSelectorField(
            label: state.make.isEmpty ? 'Select make' : state.make,
            isPlaceholder: state.make.isEmpty,
            onTap: () => showCarMakePickerSheet(
              context: context,
              onSelected: (make) {
                notifier.updateMake(make.name, []);
                notifier.updateMakeSlug(make.slug);
                notifier.clearTrim();
              },
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: state.make.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'MODEL',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CatalogueSelectorField(
                        label: state.model.isEmpty
                            ? 'Select model'
                            : state.model,
                        isPlaceholder: state.model.isEmpty,
                        onTap: () {
                          final slug = state.makeSlug;
                          if (slug == null || slug.isEmpty) return;
                          showCarModelPickerSheet(
                            context: context,
                            makeSlug: slug,
                            onSelected: (model) {
                              notifier.updateModel(model.name);
                              notifier.updateModelSlug(model.slug);
                            },
                          );
                        },
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          _TrimSection(state: state, notifier: notifier),
          if (!state.isNewVehicle) ...[
            const SizedBox(height: 16),
            Text(
              'YEAR RANGE',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: YearSelectorField(
                    heading: 'From',
                    value: state.yearMin,
                    years: _years,
                    onChanged: notifier.updateYearFrom,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: YearSelectorField(
                    heading: 'To',
                    value: state.yearMax,
                    years: yearsTo,
                    onChanged: notifier.updateYearTo,
                  ),
                ),
              ],
            ),
          ],
          _EstimatePill(state: state),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _TrimSection extends ConsumerWidget {
  final PreferenceFormState state;
  final PreferenceFormNotifier notifier;

  const _TrimSection({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slug = state.makeSlug;
    if (slug == null || slug.isEmpty || state.model.isEmpty) {
      return const SizedBox.shrink();
    }
    final modelsAsync = ref.watch(carModelsProvider(slug));
    final models = modelsAsync.valueOrNull ?? [];
    CarModel? selectedModel;
    for (final m in models) {
      if (m.slug == state.modelSlug) {
        selectedModel = m;
        break;
      }
    }
    final trims = selectedModel?.trims ?? [];
    if (trims.isEmpty || state.isNewVehicle) {
      return const SizedBox.shrink();
    }
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            'TRIM (OPTIONAL)',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                TrimChip(
                  label: 'Any trim',
                  selected: state.trim == null,
                  onTap: () => notifier.updateTrim(null),
                ),
                ...trims.map(
                  (t) => TrimChip(
                    label: t,
                    selected: state.trim == t,
                    onTap: () => notifier.updateTrim(t),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EstimatePill extends ConsumerWidget {
  final PreferenceFormState state;

  const _EstimatePill({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isNewVehicle ||
        state.makeSlug == null ||
        state.modelSlug == null ||
        state.makeSlug!.isEmpty ||
        state.modelSlug!.isEmpty) {
      return const SizedBox.shrink();
    }
    final estimate = ref.watch(liveCostEstimateProvider).valueOrNull;
    if (estimate == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.successMutedBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.successMutedBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: AppColors.successMutedForeground,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Est. auction price: ~GHS ${estimate.ghs.toStringAsFixed(0)}',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.successMutedForeground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepConditionMileage extends StatelessWidget {
  final PreferenceFormState state;
  final PreferenceFormNotifier notifier;

  const _StepConditionMileage({required this.state, required this.notifier});

  static const List<(int, String)> _mileageOptions = [
    (50000, 'Up to 50,000 mi — lowest mileage'),
    (70000, 'Up to 70,000 mi — good balance'),
    (100000, 'Up to 100,000 mi — budget friendly'),
    (200000, 'No preference'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: PreferencesResponsiveColumn(
        children: [
          const SizedBox(height: 8),
          Text(
            'Vehicle condition',
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            state.isChina
                ? 'What condition would you prefer?'
                : 'What condition are you looking for?',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          if (state.isUsOrDubai) ...[
            ConditionOptionCard(
              icon: Icons.check_circle_outline,
              iconColor: AppColors.success,
              title: 'Run & drive',
              subtitle: 'Minor cosmetic damage only. Best value for money.',
              badge: 'Most popular',
              badgeBackground: AppColors.successMutedBackground,
              badgeTextColor: AppColors.successMutedForeground,
              selected: state.condition == PreferenceCondition.readyToDrive,
              onTap: () =>
                  notifier.updateCondition(PreferenceCondition.readyToDrive),
            ),
            const SizedBox(height: 10),
            ConditionOptionCard(
              icon: Icons.build_outlined,
              iconColor: AppColors.warning,
              title: 'Repairable',
              subtitle: 'Body or mechanical damage. Lower purchase price.',
              badge: 'Lower price',
              badgeBackground: AppColors.amberBackground,
              badgeTextColor: AppColors.amberText,
              selected:
                  state.condition == PreferenceCondition.needsModerateRepair,
              onTap: () => notifier.updateCondition(
                PreferenceCondition.needsModerateRepair,
              ),
            ),
            const SizedBox(height: 10),
            ConditionOptionCard(
              icon: Icons.warning_amber_outlined,
              iconColor: AppColors.danger,
              title: 'Full rebuild',
              subtitle: 'Major damage. Significant repair investment required.',
              badge: 'Lowest price',
              badgeBackground: AppColors.dangerMutedBackground,
              badgeTextColor: AppColors.dangerMutedText,
              selected:
                  state.condition == PreferenceCondition.fullRebuildProject,
              onTap: () => notifier.updateCondition(
                PreferenceCondition.fullRebuildProject,
              ),
            ),
          ],
          if (state.isChina && !state.isNewVehicle) ...[
            ConditionOptionCard(
              icon: Icons.thumb_up_outlined,
              iconColor: AppColors.success,
              title: 'Good condition',
              subtitle: 'Low mileage, no significant damage.',
              selected: state.condition == PreferenceCondition.goodCondition,
              onTap: () =>
                  notifier.updateCondition(PreferenceCondition.goodCondition),
            ),
            const SizedBox(height: 10),
            ConditionOptionCard(
              icon: Icons.thumbs_up_down_outlined,
              iconColor: AppColors.warning,
              title: 'Fair condition',
              subtitle: 'Moderate use, acceptable wear.',
              selected: state.condition == PreferenceCondition.fairCondition,
              onTap: () =>
                  notifier.updateCondition(PreferenceCondition.fairCondition),
            ),
          ],
          if (!state.isNewVehicle) ...[
            const SizedBox(height: 24),
            Text(
              'MAXIMUM MILEAGE',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 8),
            for (final e in _mileageOptions) ...[
              SelectablePreferenceTile(
                title: e.$2,
                selected: state.maxMileage == e.$1,
                onTap: () => notifier.updateMaxMileage(e.$1),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 16),
            Text(
              'REPAIR SERVICE',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SelectablePreferenceTile(
                    title: 'Yes, arrange repairs',
                    selected: state.repairOptedIn,
                    onTap: () => notifier.updateRepairOptedIn(true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SelectablePreferenceTile(
                    title: 'No, I\'ll handle it',
                    selected: !state.repairOptedIn,
                    onTap: () => notifier.updateRepairOptedIn(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Agent sends repair quote before any work starts.',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _StepReview extends ConsumerWidget {
  final PreferenceFormState state;
  final PreferenceFormNotifier notifier;

  const _StepReview({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estimate = ref.watch(liveCostEstimateProvider).valueOrNull;

    return SingleChildScrollView(
      child: PreferencesResponsiveColumn(
        children: [
          const SizedBox(height: 8),
          Text(
            'Review your request',
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Check everything looks right before we find your agent.',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderSolid, width: 0.5),
              boxShadow: [
                BoxShadow(
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                  color: Colors.black.withValues(alpha: 0.06),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${state.make} ${state.model}',
                        style: GoogleFonts.dmSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.isSingleYear
                            ? '${state.yearMin}'
                            : '${state.yearMin}–${state.yearMax}',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (state.trim != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Trim: ${state.trim}',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
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
                      onPressed: () => notifier.goToStep(2),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
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
          ),
          const SizedBox(height: 12),
          if (!state.isNewVehicle)
            CardContainer(
              paddingType: CardContainerPaddingType.large,
              child: Column(
                children: [
                  ReviewKeyValueRow(
                    label: 'Condition',
                    value: preferenceConditionUiLabel(state.condition),
                    onEdit: () => notifier.goToStep(3),
                  ),
                  ReviewKeyValueRow(
                    label: 'Max mileage',
                    value: state.maxMileage == 200000
                        ? 'No preference'
                        : '${(state.maxMileage / 1000).round()}k mi',
                    onEdit: () => notifier.goToStep(3),
                  ),
                  ReviewKeyValueRow(
                    label: 'Repairs',
                    value: state.repairOptedIn
                        ? 'Agent arranges'
                        : 'Self managed',
                    onEdit: () => notifier.goToStep(3),
                  ),
                ],
              ),
            ),
          if (state.isNewVehicle)
            CardContainer(
              paddingType: CardContainerPaddingType.large,
              child: ReviewKeyValueRow(
                label: 'Vehicle',
                value: 'Brand new',
                onEdit: () => notifier.goToStep(1),
              ),
            ),
          const SizedBox(height: 20),
          if (state.isNewVehicle)
            CardContainer(
              paddingType: CardContainerPaddingType.large,
              child: SizedBox(
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your agent will provide a detailed quote based on your requirements.',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (estimate != null)
            CardContainer(paddingType: CardContainerPaddingType.large,child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rough cost estimate',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '~GHS ${estimate.ghs.toStringAsFixed(0)}',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'This is an approximate estimate. Actual cost depends on the vehicle found.',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textTertiary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),),
          const SizedBox(height: 20),
          CardContainer(paddingType: CardContainerPaddingType.large,child:  Column(
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
          ),),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

String? _purchaseOriginLabel(PreferenceFormState state) {
  return AppConstants.purchaseOriginLabels[state.purchaseOrigin] ??
      (state.purchaseOrigin.isEmpty ? null : state.purchaseOrigin);
}

String? _budgetSummary(PreferenceFormState state, CostEstimate? estimate) {
  if (state.isNewVehicle) return null;
  if (estimate == null) return null;
  return '~GHS ${estimate.ghs.toStringAsFixed(0)}';
}

class _PreferencesSelectionsSummary extends ConsumerWidget {
  const _PreferencesSelectionsSummary({required this.state});

  final PreferenceFormState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sw = MediaQuery.sizeOf(context).width;
    final estimate = ref.watch(liveCostEstimateProvider).valueOrNull;
    final totalSteps = _totalSteps(state);

    return Container(
      color: AppColors.backgroundSecondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.borderSolid, width: .5),
              ),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'YOUR SELECTIONS',
                style: AppTextStyles.sectionLabel.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: AppBreakpoints.scaledFontSize(10, sw),
                  letterSpacing: .5,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SelectionRow(
                    label: 'Source',
                    value: _purchaseOriginLabel(state),
                  ),
                  _SelectionRow(
                    label: 'Make',
                    value: state.make.isEmpty ? null : state.make,
                  ),
                  _SelectionRow(
                    label: 'Model',
                    value: state.model.isEmpty ? null : state.model,
                  ),
                  _SelectionRow(
                    label: 'Budget',
                    value: _budgetSummary(state, estimate),
                  ),
                  _SelectionRow(
                    label: 'Condition',
                    value: preferenceConditionUiLabel(state.condition),
                  ),
                  const SizedBox(height: 14),
                  _StepsRemainingHint(
                    currentStep: state.currentStep,
                    totalSteps: totalSteps,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionRow extends StatelessWidget {
  const _SelectionRow({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderSolid, width: .5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          if (value != null && value!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.infoBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value!,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.infoText,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            Text(
              'Not set',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
        ],
      ),
    );
  }
}

class _StepsRemainingHint extends StatelessWidget {
  const _StepsRemainingHint({
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final stepsLeft = totalSteps - currentStep;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(color: AppColors.secondary, width: 3),
        ),
      ),
      child: Text(
        stepsLeft <= 0
            ? 'Last step'
            : '$stepsLeft step${stepsLeft == 1 ? '' : 's'} remaining',
        style: AppTextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
