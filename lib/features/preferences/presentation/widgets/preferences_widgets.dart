import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/widgets/card_container.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/layout/dashboard_layout.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/dashboard_mobile_app_bar.dart';
import '../../../catalogue/domain/entities/car_make.dart';
import '../../../catalogue/domain/entities/car_model.dart';
import '../../../catalogue/presentation/providers/car_catalogue_providers.dart';
import '../../core/preference_catalogue_utils.dart';
import '../../domain/budget_fit.dart';
import '../../domain/china_import_mode.dart';
import '../providers/preference_form_provider.dart';

/// Scroll wrapper that preserves offset across child rebuilds.
class PreferenceStepScrollView extends StatefulWidget {
  final Widget child;

  const PreferenceStepScrollView({super.key, required this.child});

  @override
  State<PreferenceStepScrollView> createState() =>
      _PreferenceStepScrollViewState();
}

class _PreferenceStepScrollViewState extends State<PreferenceStepScrollView> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _controller,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: const ClampingScrollPhysics(),
      child: widget.child,
    );
  }
}

/// Contextual budget field copy per import path.
class PreferenceBudgetCopy {
  final String hint;
  final String helper;

  const PreferenceBudgetCopy({
    required this.hint,
    required this.helper,
  });

  static PreferenceBudgetCopy forImportMode(ChinaImportMode mode) =>
      switch (mode) {
        ChinaImportMode.newFromChina => const PreferenceBudgetCopy(
            hint: 'e.g. 25000',
            helper:
                'Total budget in USD. Helps your agent find options in your range.',
          ),
        ChinaImportMode.usedFromChina => const PreferenceBudgetCopy(
            hint: 'e.g. 15000',
            helper:
                'Target purchase budget in USD. Helps your agent shortlist options.',
          ),
        ChinaImportMode.none => const PreferenceBudgetCopy(
            hint: 'e.g. 8000',
            helper:
                'Auction budget in USD. Helps your agent shortlist options.',
          ),
      };
}

/// Shimmer placeholder for preferences form rows.
class PreferencesShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const PreferencesShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class PreferencesChipRowShimmer extends StatelessWidget {
  const PreferencesChipRowShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.background,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          children: const [
            PreferencesShimmerBox(width: 108, height: 36, radius: 20),
            SizedBox(width: 8),
            PreferencesShimmerBox(width: 124, height: 36, radius: 20),
            SizedBox(width: 8),
            PreferencesShimmerBox(width: 96, height: 36, radius: 20),
          ],
        ),
      ),
    );
  }
}

/// Qualitative budget-fit spectrum for the review step (no estimate figures).
class BudgetFitSpectrumCard extends StatelessWidget {
  final BudgetFitAssessment assessment;

  const BudgetFitSpectrumCard({
    super.key,
    required this.assessment,
  });

  ({Color accent, Color background, IconData icon}) _style(BudgetFitTier tier) =>
      switch (tier) {
        BudgetFitTier.comfortableRoom => (
            accent: AppColors.success,
            background: AppColors.successMutedBackground,
            icon: Icons.verified_outlined,
          ),
        BudgetFitTier.goodFit => (
            accent: AppColors.infoText,
            background: AppColors.infoBackground,
            icon: Icons.thumb_up_alt_outlined,
          ),
        BudgetFitTier.tightFit => (
            accent: AppColors.warning,
            background: AppColors.amberBackground,
            icon: Icons.travel_explore_outlined,
          ),
        BudgetFitTier.stretch => (
            accent: AppColors.warning,
            background: AppColors.amberBackground,
            icon: Icons.forum_outlined,
          ),
      };

  @override
  Widget build(BuildContext context) {
    final style = _style(assessment.tier);

    return Container(
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: style.background,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(style.icon, size: 18, color: style.accent),
                ),
                const SizedBox(width: 10),
                Text(
                  'Budget check',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              assessment.title,
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: style.accent,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              assessment.subtitle,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Stretch',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  'Comfortable',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            LayoutBuilder(
              builder: (context, constraints) {
                final barWidth = constraints.maxWidth;
                const pinSize = 14.0;
                final pinLeft = (barWidth * assessment.pinPosition - pinSize / 2)
                    .clamp(0.0, barWidth - pinSize);

                return Column(
                  children: [
                    SizedBox(
                      height: pinSize + 4,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: pinLeft,
                            child: Column(
                              children: [
                                Container(
                                  width: pinSize,
                                  height: pinSize,
                                  decoration: BoxDecoration(
                                    color: style.accent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.background,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 6,
                                        color: style.accent
                                            .withValues(alpha: 0.35),
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.amberBackground,
                            AppColors.infoBackground,
                            AppColors.successMutedBackground,
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.borderSolid,
                          width: 0.5,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              assessment.footer,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: AppColors.textTertiary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BudgetFitSpectrumCardShimmer extends StatelessWidget {
  const BudgetFitSpectrumCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.background,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSolid, width: 0.5),
        ),
      ),
    );
  }
}

/// Premium compact condition card for side-by-side step 1 layout.
class PreferenceCompactConditionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? badge;
  final Color? badgeBackground;
  final Color? badgeTextColor;
  final bool selected;
  final VoidCallback onTap;

  const PreferenceCompactConditionCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.badge,
    this.badgeBackground,
    this.badgeTextColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          constraints: const BoxConstraints(minHeight: 104),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? AppColors.selectionTint : AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.secondary : AppColors.borderSolid,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      blurRadius: 12,
                      color: AppColors.secondary.withValues(alpha: 0.08),
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.black.withValues(alpha: 0.03),
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(icon, color: iconColor, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        if (badge != null &&
                            badgeBackground != null &&
                            badgeTextColor != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: badgeBackground,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              badge!,
                              style: GoogleFonts.dmSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: badgeTextColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (selected)
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.check_circle,
                        size: 18,
                        color: AppColors.secondary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Uppercase section label used across preference steps.
class PreferenceSectionLabel extends StatelessWidget {
  final String text;

  const PreferenceSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.6,
        color: AppColors.textTertiary,
      ),
    );
  }
}

double _preferencesHorizontalPadding(BuildContext context) {
  if (AppBreakpoints.useMobileShell(context)) {
    return DashboardLayout.bodyContentHorizontalPadding(context);
  }
  return DashboardLayout.flowScrollPadding(context).horizontal;
}

/// Mobile shell: centred column with max width. Web shell: full panel width.
class PreferencesResponsiveColumn extends StatelessWidget {
  final List<Widget> children;

  const PreferencesResponsiveColumn({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final horizontal = _preferencesHorizontalPadding(context);
    final column = Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );

    if (AppBreakpoints.useWebShell(context)) {
      return column;
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: DashboardLayout.contentColumnMaxWidth(context),
        ),
        child: column,
      ),
    );
  }
}

class PreferencesStepProgressBar extends StatelessWidget {
  final int displayStep;
  final int totalSteps;
  final String? stepLabel;

  const PreferencesStepProgressBar({
    super.key,
    required this.displayStep,
    required this.totalSteps,
    this.stepLabel,
  });

  @override
  Widget build(BuildContext context) {
    final t = totalSteps.clamp(1, 99);
    final c = displayStep.clamp(1, t);
    final horizontal = _preferencesHorizontalPadding(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontal, 14, horizontal, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Step $c of $t',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondary,
                ),
              ),
              if (stepLabel != null) ...[
                const SizedBox(width: 8),
                Text(
                  '·',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  stepLabel!,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(t, (i) {
              final stepNum = i + 1;
              final completed = stepNum < c;
              final active = stepNum == c;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  height: 3,
                  margin: EdgeInsets.only(right: i < t - 1 ? 5 : 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: completed || active
                        ? AppColors.secondary
                        : AppColors.borderSolid,
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: AppColors.secondary.withValues(alpha: 0.35),
                              blurRadius: 6,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class PreferencesPrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback? onTap;

  const PreferencesPrimaryButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppPrimaryButton(
      label: label,
      onPressed: onTap,
      isLoading: isLoading,
      enabled: isEnabled,
      height: 52,
      prominent: true,
      textStyle: GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.onBrand,
      ),
    );
  }
}

class PreferencesBottomNavBar extends StatelessWidget {
  final PreferenceFormState state;
  final PreferenceFormNotifier notifier;
  final VoidCallback onConfirm;
  final VoidCallback? onBeforeAction;
  final bool isLoading;

  const PreferencesBottomNavBar({
    super.key,
    required this.state,
    required this.notifier,
    required this.onConfirm,
    this.onBeforeAction,
    this.isLoading = false,
  });

  bool _canProceed(PreferenceFormState s) {
    return switch (s.currentStep) {
      1 => s.canProceedFromCar,
      2 => true,
      _ => false,
    };
  }

  String? _disabledHint(PreferenceFormState s) {
    if (s.currentStep == 1 && !s.canProceedFromCar) {
      return 'Select a make and model to continue';
    }
    return null;
  }

  bool get _isLastStep => state.currentStep == 2;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final useMobileShell = AppBreakpoints.useMobileShell(context);
    final horizontal = _preferencesHorizontalPadding(context);
    return Container(
      padding: EdgeInsets.fromLTRB(horizontal, 14, horizontal, 14 + bottom),
      decoration: BoxDecoration(
        color: useMobileShell ? AppColors.surface : AppColors.background,
        border: const Border(
          top: BorderSide(color: AppColors.borderSolid, width: 0.5),
        ),
        boxShadow: useMobileShell
            ? null
            : [
                BoxShadow(
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                  color: Colors.black.withValues(alpha: 0.04),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (state.currentStep > 1) ...[
            if (useMobileShell)
              DashboardAppBarIconButton(
                icon: Icons.arrow_back_ios_new,
                size: 52,
                onPressed: notifier.previousStep,
              )
            else
              Material(
                color: Colors.transparent,
                child: CardContainer(
                  paddingType: CardContainerPaddingType.none,
                  child: InkWell(
                    onTap: notifier.previousStep,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 52,
                      width: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderSolid),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_disabledHint(state) != null) ...[
                  Text(
                    _disabledHint(state)!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                PreferencesPrimaryButton(
                  label:
                      _isLastStep ? 'Confirm & find my agent →' : 'Continue →',
                  isLoading: isLoading,
                  isEnabled: _canProceed(state),
                  onTap: () {
                    onBeforeAction?.call();
                    if (_isLastStep) {
                      onConfirm();
                    } else {
                      notifier.nextStep();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CatalogueSelectorField extends StatelessWidget {
  final String label;
  final bool isPlaceholder;
  final VoidCallback? onTap;
  final bool isEnabled;

  const CatalogueSelectorField({
    super.key,
    required this.label,
    required this.isPlaceholder,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final canTap = isEnabled && onTap != null;
    return Opacity(
      opacity: canTap ? 1 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canTap ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(
                color: canTap ? AppColors.borderSolid : AppColors.borderSolid,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                  color: Colors.black.withValues(alpha: 0.03),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isPlaceholder
                          ? AppColors.textTertiary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TrimChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const TrimChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.secondary : AppColors.background,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? AppColors.secondary : AppColors.borderSolid,
              ),
            ),
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class YearSelectorField extends StatelessWidget {
  final String heading;
  final int value;
  final List<int> years;
  final ValueChanged<int> onChanged;
  final bool showHeading;

  const YearSelectorField({
    super.key,
    required this.heading,
    required this.value,
    required this.years,
    required this.onChanged,
    this.showHeading = true,
  });

  Future<void> _openSheet(BuildContext context) async {
    final chosen = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(ctx).height * 0.55,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderSolid,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  heading,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: years.length,
                    itemBuilder: (_, i) {
                      final y = years[i];
                      final sel = y == value;
                      return Material(
                        color: sel
                            ? AppColors.selectionTint
                            : Colors.transparent,
                        child: ListTile(
                          minTileHeight: 48,
                          title: Text(
                            '$y',
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          trailing: sel
                              ? Icon(
                                  Icons.check_circle,
                                  color: AppColors.secondary,
                                )
                              : null,
                          onTap: () => Navigator.pop(ctx, y),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (chosen != null) onChanged(chosen);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeading) ...[
          Text(
            heading.toUpperCase(),
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openSheet(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border.all(color: AppColors.borderSolid),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                    color: Colors.black.withValues(alpha: 0.03),
                  ),
                ],
              ),
              child: Text(
                '$value',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class OriginCard extends StatelessWidget {
  final String origin;
  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const OriginCard({
    super.key,
    required this.origin,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? AppColors.selectionTint : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.secondary : AppColors.borderSolid,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 24, color: AppColors.secondary),
              const SizedBox(width: 14),
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
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, size: 20, color: AppColors.secondary),
            ],
          ),
        ),
      ),
    );
  }
}

class OriginPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const OriginPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.secondary : AppColors.background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.secondary : AppColors.borderSolid,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class OriginBadge extends StatelessWidget {
  final String purchaseOrigin;

  const OriginBadge({super.key, required this.purchaseOrigin});

  @override
  Widget build(BuildContext context) {
    if (purchaseOrigin == AppConstants.purchaseOriginAny) {
      return const SizedBox.shrink();
    }
    final label = AppConstants.purchaseOriginLabels[purchaseOrigin] ?? '';
    Color bg;
    Color fg;
    switch (purchaseOrigin) {
      case AppConstants.purchaseOriginUsCanada:
        bg = AppColors.selectionTint;
        fg = AppColors.infoText;
      case AppConstants.purchaseOriginDubai:
        bg = AppColors.amberBackground;
        fg = AppColors.amberText;
      case AppConstants.purchaseOriginChina:
        bg = AppColors.successMutedBackground;
        fg = AppColors.successMutedForeground;
      default:
        bg = AppColors.surface;
        fg = AppColors.textSecondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: fg,
        ),
      ),
    );
  }
}

class ConditionOptionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? badge;
  final Color? badgeBackground;
  final Color? badgeTextColor;
  final bool selected;
  final VoidCallback onTap;

  const ConditionOptionCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.badge,
    this.badgeBackground,
    this.badgeTextColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? AppColors.selectionTint : AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.secondary : AppColors.borderSolid,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      blurRadius: 12,
                      color: AppColors.secondary.withValues(alpha: 0.08),
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.black.withValues(alpha: 0.03),
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null &&
                  badgeBackground != null &&
                  badgeTextColor != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge!,
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: badgeTextColor,
                      ),
                    ),
                  ),
                ),
              if (selected)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Icon(
                    Icons.check_circle,
                    size: 22,
                    color: AppColors.secondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectablePreferenceTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  const SelectablePreferenceTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.selectionTint : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.secondary : AppColors.borderSolid,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, color: AppColors.secondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class ReviewKeyValueRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onEdit;

  const ReviewKeyValueRow({
    super.key,
    required this.label,
    required this.value,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Text(
                  value,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
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
        ),
        Divider(height: 1, thickness: 0.5, color: AppColors.borderSolid),
      ],
    );
  }
}

class NextStepRow extends StatelessWidget {
  final int number;
  final String text;

  const NextStepRow({super.key, required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.selectionTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$number',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.infoText,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
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
    );
  }
}

class PreferencesSearchField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final bool autofocus;

  const PreferencesSearchField({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: autofocus,
      onChanged: onChanged,
      style: GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.dmSans(
          fontSize: 15,
          color: AppColors.textTertiary,
        ),
        filled: true,
        fillColor: AppColors.surface,
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
          borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        prefixIcon: Icon(Icons.search, size: 22, color: AppColors.textTertiary),
      ),
    );
  }
}

class SheetSectionHeader extends StatelessWidget {
  final String title;

  const SheetSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}

class MakeListTile extends StatelessWidget {
  final CarMake make;
  final VoidCallback onTap;

  const MakeListTile({super.key, required this.make, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final showChinaBadge =
        make.marketType == 'china' || make.marketType == 'both';
    return ListTile(
      minTileHeight: 56,
      title: Text(
        make.name,
        style: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: showChinaBadge
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.infoBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                make.marketType == 'both' ? 'Both' : 'China',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.infoText,
                ),
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}

class ModelListTile extends StatelessWidget {
  final CarModel model;
  final VoidCallback onTap;

  const ModelListTile({super.key, required this.model, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: 64,
      leading: model.imageUrl != null && model.imageUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: model.imageUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: AppColors.surface,
                  highlightColor: AppColors.background,
                  child: Container(
                    width: 48,
                    height: 48,
                    color: AppColors.surface,
                  ),
                ),
                errorWidget: (_, __, ___) =>
                    const SizedBox(width: 48, height: 48),
              ),
            )
          : null,
      title: Text(
        model.name,
        style: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        '${model.yearStart}–${model.yearEnd}',
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textTertiary,
        ),
      ),
      onTap: onTap,
    );
  }
}

class MakeSelectionSheet extends ConsumerStatefulWidget {
  final ValueChanged<CarMake> onSelected;
  final ChinaImportMode importMode;

  const MakeSelectionSheet({
    super.key,
    required this.onSelected,
    this.importMode = ChinaImportMode.none,
  });

  @override
  ConsumerState<MakeSelectionSheet> createState() => _MakeSelectionSheetState();
}

class _MakeSelectionSheetState extends ConsumerState<MakeSelectionSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final makesAsync = ref.watch(carMakesProvider);
    final popular = ref.watch(popularMakesProvider);

    return makesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Could not load makes. Check your connection and try again.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
      data: (allMakes) {
        final q = _query.trim().toLowerCase();
        final allowed = allMakes
            .where((m) => isMakeAllowedForImportMode(m, widget.importMode))
            .toList();
        List<CarMake> filtered = allowed;
        if (q.isNotEmpty) {
          filtered = allowed
              .where((m) => m.name.toLowerCase().startsWith(q))
              .toList();
        }
        final popularFiltered = (q.isEmpty ? popular : popular)
            .where((m) => isMakeAllowedForImportMode(m, widget.importMode))
            .where((m) => q.isEmpty || m.name.toLowerCase().startsWith(q))
            .toList();
        final popularSlugs = popularFiltered.map((e) => e.slug).toSet();
        final restMakes = q.isEmpty
            ? allowed.where((m) => !popularSlugs.contains(m.slug)).toList()
            : filtered;

        return Column(
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderSolid,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PreferencesSearchField(
                hintText: 'Search makes…',
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  if (q.isEmpty && popularFiltered.isNotEmpty) ...[
                    const SheetSectionHeader(title: 'POPULAR'),
                    ...popularFiltered.map(
                      (m) => MakeListTile(
                        make: m,
                        onTap: () => widget.onSelected(m),
                      ),
                    ),
                    const SheetSectionHeader(title: 'ALL MAKES'),
                    ...restMakes.map(
                      (m) => MakeListTile(
                        make: m,
                        onTap: () => widget.onSelected(m),
                      ),
                    ),
                  ] else
                    ...filtered.map(
                      (m) => MakeListTile(
                        make: m,
                        onTap: () => widget.onSelected(m),
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

class ModelSelectionSheet extends ConsumerStatefulWidget {
  final String makeSlug;
  final ValueChanged<CarModel> onSelected;

  const ModelSelectionSheet({
    super.key,
    required this.makeSlug,
    required this.onSelected,
  });

  @override
  ConsumerState<ModelSelectionSheet> createState() =>
      _ModelSelectionSheetState();
}

class _ModelSelectionSheetState extends ConsumerState<ModelSelectionSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final modelsAsync = ref.watch(carModelsProvider(widget.makeSlug));

    return modelsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: Text(
          'Could not load models.',
          style: GoogleFonts.dmSans(color: AppColors.textSecondary),
        ),
      ),
      data: (models) {
        final q = _query.trim().toLowerCase();
        final filtered = q.isEmpty
            ? models
            : models.where((m) => m.name.toLowerCase().startsWith(q)).toList();

        return Column(
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderSolid,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PreferencesSearchField(
                hintText: 'Search models…',
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final m = filtered[i];
                  return ModelListTile(
                    model: m,
                    onTap: () => widget.onSelected(m),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

Future<void> showCarMakePickerSheet({
  required BuildContext context,
  required ValueChanged<CarMake> onSelected,
  ChinaImportMode importMode = ChinaImportMode.none,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      final h = MediaQuery.sizeOf(ctx).height * 0.92;
      return SizedBox(
        height: h,
        child: MakeSelectionSheet(
          importMode: importMode,
          onSelected: (make) {
            Navigator.of(ctx).pop();
            onSelected(make);
          },
        ),
      );
    },
  );
}

Future<void> showCarModelPickerSheet({
  required BuildContext context,
  required String makeSlug,
  required ValueChanged<CarModel> onSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      final h = MediaQuery.sizeOf(ctx).height * 0.92;
      return SizedBox(
        height: h,
        child: ModelSelectionSheet(
          makeSlug: makeSlug,
          onSelected: (model) {
            Navigator.of(ctx).pop();
            onSelected(model);
          },
        ),
      );
    },
  );
}
