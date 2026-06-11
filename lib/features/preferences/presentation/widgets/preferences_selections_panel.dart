import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/china_import_mode.dart';
import '../providers/preference_form_provider.dart';

class PreferencesSelectionsPanel extends ConsumerWidget {
  const PreferencesSelectionsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(preferenceFormProvider);
    final sw = MediaQuery.sizeOf(context).width;

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
                  _row('Import', _importLabel(state)),
                  _row('Make', state.make.isEmpty ? null : state.make),
                  _row('Model', state.model.isEmpty ? null : state.model),
                  if (state.trim != null) _row('Trim', state.trim),
                  _row(
                    'Year',
                    state.isNewVehicle
                        ? null
                        : state.isSingleYear
                            ? '${state.yearMin}'
                            : '${state.yearMin}–${state.yearMax}',
                  ),
                  if (!state.isNewVehicle)
                    _row(
                      'Condition',
                      preferenceConditionUiLabel(state.condition),
                    ),
                  if (_budgetUsd(ref) != null)
                    _row(
                      'Budget',
                      CurrencyFormatter.formatUsd(_budgetUsd(ref)!.toDouble()),
                    ),
                  const SizedBox(height: 14),
                  _stepsHint(state),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int? _budgetUsd(WidgetRef ref) =>
      ref.watch(preferenceFormProvider.select((s) => s.maxBudgetUsd));

  String? _importLabel(PreferenceFormState state) {
    return switch (state.chinaImportMode) {
      ChinaImportMode.newFromChina => 'Brand new from China',
      ChinaImportMode.usedFromChina => 'Used from China',
      ChinaImportMode.none =>
        AppConstants.purchaseOriginLabels[state.advancedPurchaseOrigin],
    };
  }

  Widget _row(String label, String? value) {
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
          if (value != null && value.isNotEmpty)
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.infoBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  value,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.infoText,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
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

  Widget _stepsHint(PreferenceFormState state) {
    final left = state.totalSteps - state.displayStep;
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
        left <= 0
            ? 'Last step — confirm to find your agent'
            : '$left step${left == 1 ? '' : 's'} remaining',
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
