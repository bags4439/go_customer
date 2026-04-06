import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../guide/core/constants/guide_keys.dart';
import '../../../guide/presentation/providers/guide_providers.dart';
import '../../../guide/presentation/widgets/coach_mark_overlay.dart';
import '../../../guide/presentation/widgets/guide_faq_sheet.dart';
import '../../../guide/presentation/widgets/guide_help_button.dart';
import '../../../guide/presentation/widgets/spotlight_painter.dart';
import '../../core/constants/repair_constants.dart';
import '../../domain/entities/repair_job.dart';
import '../../../clearance/presentation/providers/clearance_providers.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../providers/repair_providers.dart';

final _dateFormat = DateFormat('d MMM yyyy');

class RepairScreen extends ConsumerStatefulWidget {
  final String orderId;

  const RepairScreen({super.key, required this.orderId});

  @override
  ConsumerState<RepairScreen> createState() => _RepairScreenState();
}

class _RepairScreenState extends ConsumerState<RepairScreen> {
  final GlobalKey _repairCoachKey = GlobalKey();
  bool _showRepairCoach = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowRepairCoach());
  }

  bool _repairCoachEligible(RepairScreenState state) {
    return state != RepairScreenState.notAvailable &&
        state != RepairScreenState.noRepair;
  }

  Future<void> _maybeShowRepairCoach() async {
    if (!mounted) return;
    final screenState = ref.read(repairScreenStateProvider(widget.orderId));
    if (!_repairCoachEligible(screenState)) return;
    final seen = await ref.read(
      hasSeenGuideProvider(GuideKeys.stageRepair).future,
    );
    if (!seen && mounted) {
      setState(() => _showRepairCoach = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenState = ref.watch(repairScreenStateProvider(widget.orderId));
    final jobAsync = ref.watch(repairJobProvider(widget.orderId));
    final dutyAsync = ref.watch(dutyClearanceProvider(widget.orderId));
    final repairOptedInAsync = ref.watch(
      carPreferencesRepairOptedInProvider(widget.orderId),
    );

    final isLoading =
        jobAsync.isLoading ||
        dutyAsync.isLoading ||
        (screenState == RepairScreenState.choice &&
            repairOptedInAsync.isLoading);
    final hasError = jobAsync.hasError || dutyAsync.hasError;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
          style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
        ),
        title: Text(
          'Repairs',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        actions: [
          GuideHelpButton(
            onShowGuide: () => setState(() => _showRepairCoach = true),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: ref
                  .watch(orderProvider(widget.orderId))
                  .when(
                    data: (order) => Text(
                      order?.orderRef ?? widget.orderId,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppColors.primary.withValues(alpha: 0.7),
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          KeyedSubtree(
            key: _repairCoachKey,
            child: hasError
                ? _RepairErrorCard(
                    orderId: widget.orderId,
                    onRetry: () {
                      ref.invalidate(repairJobProvider(widget.orderId));
                      ref.invalidate(dutyClearanceProvider(widget.orderId));
                      ref.invalidate(
                        carPreferencesRepairOptedInProvider(widget.orderId),
                      );
                    },
                  )
                : isLoading
                    ? const _RepairLoadingBody()
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _RepairBody(
                          key: ValueKey(screenState),
                          orderId: widget.orderId,
                          screenState: screenState,
                          job: jobAsync.valueOrNull,
                          dutyClearedAt: dutyAsync.valueOrNull?.clearedAt,
                          repairOptedIn: repairOptedInAsync.valueOrNull,
                        ),
                      ),
          ),
          if (_showRepairCoach && _repairCoachEligible(screenState))
            CoachMarkOverlay(
              guideKey: GuideKeys.stageRepair,
              targetKey: _repairCoachKey,
              title: 'Review your repair quote',
              body: 'Your agent sent a repair quote. '
                  'Check the details carefully — '
                  'no work begins until you approve it.',
              spotlightShape: SpotlightShape.roundedRect,
              onDismiss: () => setState(() => _showRepairCoach = false),
              onFaqTap: () {
                setState(() => _showRepairCoach = false);
                GuideFaqSheet.show(context);
              },
            ),
        ],
      ),
    );
  }
}

class _RepairErrorCard extends StatelessWidget {
  final String orderId;
  final VoidCallback onRetry;

  const _RepairErrorCard({required this.orderId, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.danger),
            const SizedBox(height: 16),
            Text(
              RepairConstants.errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(fontSize: 16, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RepairLoadingBody extends StatelessWidget {
  const _RepairLoadingBody();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Shimmer.fromColors(
            baseColor: AppColors.surface,
            highlightColor: Colors.white,
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Shimmer.fromColors(
            baseColor: AppColors.surface,
            highlightColor: Colors.white,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Shimmer.fromColors(
            baseColor: AppColors.surface,
            highlightColor: Colors.white,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Shimmer.fromColors(
            baseColor: AppColors.surface,
            highlightColor: Colors.white,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RepairBody extends StatelessWidget {
  final String orderId;
  final RepairScreenState screenState;
  final RepairJob? job;
  final DateTime? dutyClearedAt;
  final bool? repairOptedIn;

  const _RepairBody({
    super.key,
    required this.orderId,
    required this.screenState,
    required this.job,
    required this.dutyClearedAt,
    required this.repairOptedIn,
  });

  @override
  Widget build(BuildContext context) {
    switch (screenState) {
      case RepairScreenState.notAvailable:
        return _State0NotAvailable(orderId: orderId);
      case RepairScreenState.choice:
        return _State1Choice(
          orderId: orderId,
          dutyClearedAt: dutyClearedAt,
          repairOptedIn: repairOptedIn,
        );
      case RepairScreenState.awaitingQuote:
        return _StateAwaitingQuote(orderId: orderId);
      case RepairScreenState.quoteSent:
        return _State2QuoteReceived(orderId: orderId, job: job!);
      case RepairScreenState.quoteDeclined:
        return _State2BQuoteDeclined(orderId: orderId);
      case RepairScreenState.inProgress:
        return _State3InProgress(orderId: orderId, job: job!);
      case RepairScreenState.complete:
        return _State4Complete(orderId: orderId, job: job!);
      case RepairScreenState.noRepair:
        return _State5NoRepair(orderId: orderId);
    }
  }
}

class _State0NotAvailable extends StatelessWidget {
  final String orderId;

  const _State0NotAvailable({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.build_outlined, size: 80, color: Colors.grey.shade500),
            const SizedBox(height: 24),
            Text(
              RepairConstants.state0Heading,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              RepairConstants.state0Body,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: () => context.go('/order/$orderId'),
                child: const Text(RepairConstants.state0BackButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _State1Choice extends ConsumerStatefulWidget {
  final String orderId;
  final DateTime? dutyClearedAt;
  final bool? repairOptedIn;

  const _State1Choice({
    required this.orderId,
    required this.dutyClearedAt,
    required this.repairOptedIn,
  });

  @override
  ConsumerState<_State1Choice> createState() => _State1ChoiceState();
}

class _State1ChoiceState extends ConsumerState<_State1Choice>
    with SingleTickerProviderStateMixin {
  late AnimationController _clearedBarController;
  bool _choiceInitialized = false;

  @override
  void initState() {
    super.initState();
    _clearedBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_choiceInitialized && widget.repairOptedIn != null) {
      _choiceInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(repairChoiceProvider(widget.orderId).notifier).state =
            widget.repairOptedIn;
      });
    }
  }

  @override
  void dispose() {
    _clearedBarController.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    final choice = ref
        .read(repairChoiceProvider(widget.orderId).notifier)
        .state;
    if (choice == null) return;
    final repo = ref.read(repairRepositoryProvider);
    setState(() => _isSubmitting = true);
    final result = await repo.confirmRepairs(
      orderId: widget.orderId,
      optedIn: choice,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    result.fold(
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(RepairConstants.writeErrorMessage)),
      ),
      (_) {},
    );
  }

  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final choice = ref.watch(repairChoiceProvider(widget.orderId));
    final agentName =
        ref.watch(agentFirstNameProvider(widget.orderId)).valueOrNull ??
        'Your agent';
    final estimateAsync = ref.watch(repairEstimateProvider(widget.orderId));
    final estimate = estimateAsync.valueOrNull;
    final estimateStr = estimate != null
        ? '~${CurrencyFormatter.formatGhs(estimate)}'
        : RepairConstants.estVaries;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          _ClearedBar(
            animation: _clearedBarController,
            clearedAt: widget.dutyClearedAt,
          ),
          if (widget.repairOptedIn != null) ...[
            const SizedBox(height: 16),
            _PreferenceReminder(repairOptedIn: widget.repairOptedIn!),
          ],
          const SizedBox(height: 20),
          Text(
            RepairConstants.state1Heading,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          _RepairOptionCard(
            orderId: widget.orderId,
            isYes: true,
            isSelected: choice == true,
            estimateLabel: estimateStr,
            agentFirstName: agentName,
          ),
          const SizedBox(height: 12),
          _RepairOptionCard(
            orderId: widget.orderId,
            isYes: false,
            isSelected: choice == false,
            estimateLabel: null,
            agentFirstName: agentName,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${RepairConstants.infoNote} ${RepairConstants.infoNoteSuffix(agentName)}',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {},
            child: Text(
              RepairConstants.seeGaragePartners,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: AppColors.secondary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _RepairConfirmButton(
            choice: choice,
            isSubmitting: _isSubmitting,
            onConfirm: _onConfirm,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ClearedBar extends StatelessWidget {
  final Animation<double> animation;
  final DateTime? clearedAt;

  const _ClearedBar({required this.animation, this.clearedAt});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF3DE),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: const Color(0xFFC0DD97)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    RepairConstants.clearedBarTitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF27500A),
                    ),
                  ),
                  if (clearedAt != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _dateFormat.format(clearedAt!),
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: const Color(0xFF3B6D11),
                      ),
                    ),
                  ] else
                    Text(
                      RepairConstants.clearedBarSubtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: const Color(0xFF3B6D11),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreferenceReminder extends StatelessWidget {
  final bool repairOptedIn;

  const _PreferenceReminder({required this.repairOptedIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: repairOptedIn ? const Color(0xFFE6F1FB) : AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Text(
        repairOptedIn
            ? RepairConstants.reminderOptedIn
            : RepairConstants.reminderOptedOut,
        style: GoogleFonts.dmSans(
          fontSize: 12,
          color: repairOptedIn
              ? const Color(0xFF185FA5)
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
        ),
      ),
    );
  }
}

class _RepairOptionCard extends ConsumerWidget {
  final String orderId;
  final bool isYes;
  final bool isSelected;
  final String? estimateLabel;
  final String agentFirstName;

  const _RepairOptionCard({
    required this.orderId,
    required this.isYes,
    required this.isSelected,
    required this.estimateLabel,
    required this.agentFirstName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(repairChoiceProvider(orderId).notifier);
    final bullets = isYes
        ? [
            RepairConstants.optionYesBullet1,
            RepairConstants.optionYesBullet2,
            RepairConstants.optionYesBullet3,
            RepairConstants.optionYesBullet4,
          ]
        : [
            RepairConstants.optionNoBullet1,
            RepairConstants.optionNoBullet2,
            RepairConstants.optionNoBullet3(agentFirstName),
          ];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => notifier.state = isYes,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEBF4FD) : Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: isSelected ? AppColors.secondary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isYes
                          ? const Color(0xFFE6F1FB)
                          : AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isYes ? Icons.build : Icons.directions_car,
                      size: 22,
                      color: isYes ? AppColors.secondary : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isYes
                              ? RepairConstants.optionYesTitle
                              : RepairConstants.optionNoTitle,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? AppColors.secondary
                                : AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (estimateLabel != null)
                              Text(
                                estimateLabel!,
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            else
                              Text(
                                RepairConstants.optionNoPrice,
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.success,
                                ),
                              ),
                            const SizedBox(width: 4),
                            Text(
                              isYes
                                  ? RepairConstants.optionYesPriceLabel
                                  : RepairConstants.optionNoPriceLabel,
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? AppColors.secondary
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.secondary
                            : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: isSelected
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMd,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: bullets
                                .map(
                                  (b) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '• ',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 12,
                                            color: isYes
                                                ? AppColors.success
                                                : null,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            b,
                                            style: GoogleFonts.dmSans(
                                              fontSize: 12,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.85),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RepairConfirmButton extends StatelessWidget {
  final bool? choice;
  final bool isSubmitting;
  final VoidCallback onConfirm;

  const _RepairConfirmButton({
    required this.choice,
    required this.isSubmitting,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = choice != null && !isSubmitting;
    final label = choice == true
        ? RepairConstants.confirmYesButton
        : choice == false
        ? RepairConstants.confirmNoButton
        : RepairConstants.confirmButtonSelectOption;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      height: 48,
      child: ElevatedButton(
        onPressed: enabled ? onConfirm : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled
              ? AppColors.secondary
              : const Color(0xFFE0DFD8),
          foregroundColor: enabled ? Colors.white : const Color(0xFFAAAAAA),
          disabledBackgroundColor: const Color(0xFFE0DFD8),
          disabledForegroundColor: const Color(0xFFAAAAAA),
        ),
        child: isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    );
  }
}

class _State2QuoteReceived extends ConsumerStatefulWidget {
  final String orderId;
  final RepairJob job;

  const _State2QuoteReceived({required this.orderId, required this.job});

  @override
  ConsumerState<_State2QuoteReceived> createState() =>
      _State2QuoteReceivedState();
}

class _State2QuoteReceivedState extends ConsumerState<_State2QuoteReceived> {
  bool _accepting = false;
  bool _declining = false;

  @override
  Widget build(BuildContext context) {
    final agentName =
        ref.watch(agentFirstNameProvider(widget.orderId)).valueOrNull ??
        'Your agent';
    final garageAsync = ref.watch(garageDetailsProvider(widget.job.garageId));
    final garage = garageAsync.valueOrNull;
    final garageName = widget.job.garageNameCustom ?? garage?.name ?? '—';
    final garageLocation = widget.job.garageLocation ?? garage?.location ?? '—';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Text(
            RepairConstants.state2Heading(agentName),
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            RepairConstants.state2Subtitle,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            garageName,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            garageLocation,
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAEEDA),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        RepairConstants.quoteBadge,
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          color: const Color(0xFF633806),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (widget.job.workDescription != null &&
                    widget.job.workDescription!.isNotEmpty)
                  Column(
                    children: [
                      Text(
                        widget.job.workDescription!,
                        style: GoogleFonts.dmSans(fontSize: 13),
                      ),
                      SizedBox(height: 8,)
                    ],
                  ),
                if (widget.job.platformServiceFeeGhs != null) ...[
                  const SizedBox(height: 8),
                  _QuoteLineRow(
                    label: RepairConstants.platformServiceFeeLabel,
                    value: CurrencyFormatter.formatGhs(
                      widget.job.platformServiceFeeGhs!,
                    ),
                  ),
                ],
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      RepairConstants.totalLabel,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      widget.job.totalQuotedGhs != null
                          ? CurrencyFormatter.formatGhs(
                              widget.job.totalQuotedGhs!,
                            )
                          : '—',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _accepting || _declining
                        ? null
                        : () async {
                            setState(() => _accepting = true);
                            final result = await ref
                                .read(repairRepositoryProvider)
                                .acceptQuote(widget.orderId);
                            if (!mounted) return;
                            setState(() => _accepting = false);
                            result.fold(
                              (_) => ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    RepairConstants.writeErrorMessage,
                                  ),
                                ),
                              ),
                              (_) {},
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                    ),
                    child: _accepting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(RepairConstants.acceptQuoteButton),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _accepting || _declining
                        ? null
                        : () async {
                            setState(() => _declining = true);
                            final result = await ref
                                .read(repairRepositoryProvider)
                                .declineQuote(widget.orderId);
                            if (!mounted) return;
                            setState(() => _declining = false);
                            result.fold(
                              (_) => ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    RepairConstants.writeErrorMessage,
                                  ),
                                ),
                              ),
                              (_) {},
                            );
                          },
                    child: _declining
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(RepairConstants.declineQuoteButton),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GarageInfoRow(
                  label: RepairConstants.garageLabel,
                  value: garageName,
                ),
                _GarageInfoRow(
                  label: RepairConstants.locationLabel,
                  value: garageLocation,
                ),
                if (garage?.isVetted == true) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      RepairConstants.vettedBadge,
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
                if (garage?.rating != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    '★ ${garage!.rating!.toStringAsFixed(1)}',
                    style: GoogleFonts.dmSans(fontSize: 12),
                  ),
                ],
                if (widget.job.estimatedCompletion != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    '${RepairConstants.estCompletionLabel}: ${_dateFormat.format(widget.job.estimatedCompletion!)}',
                    style: GoogleFonts.dmSans(fontSize: 12),
                  ),
                ],
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => context.go('/order/${widget.orderId}?tab=chat'),
                  child: Text(
                    RepairConstants.askSecondQuote(agentName),
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.secondary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _QuoteLineRow extends StatelessWidget {
  final String label;
  final String value;

  const _QuoteLineRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.dmSans(fontSize: 12)),
        SizedBox(width: 16),
        Flexible(child: Text(value, style: GoogleFonts.dmSans(fontSize: 12))),
      ],
    );
  }
}

class _GarageInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _GarageInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ),
          Expanded(child: Text(value, style: GoogleFonts.dmSans(fontSize: 11))),
        ],
      ),
    );
  }
}

class _State2BQuoteDeclined extends ConsumerWidget {
  final String orderId;

  const _State2BQuoteDeclined({required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentName =
        ref.watch(agentFirstNameProvider(orderId)).valueOrNull ?? 'Your agent';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  RepairConstants.state2BHeading,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  RepairConstants.state2BBody(agentName),
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _PulsingDots(),
          const SizedBox(height: 32),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () => context.go('/order/$orderId?tab=chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
              child: Text(RepairConstants.askAgentButton(agentName)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDots extends StatefulWidget {
  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final delay = i * 0.2;
            final t = ((_controller.value - delay).clamp(0.0, 1.0) * 2 - 1)
                .abs();
            final opacity = 0.3 + 0.7 * (1 - t);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: opacity),
              ),
            );
          }),
        );
      },
    );
  }
}

class _State3InProgress extends ConsumerStatefulWidget {
  final String orderId;
  final RepairJob job;

  const _State3InProgress({required this.orderId, required this.job});

  @override
  ConsumerState<_State3InProgress> createState() => _State3InProgressState();
}

class _State3InProgressState extends ConsumerState<_State3InProgress>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  final List<bool> _stageVisible = [false, false, false, false, false];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    for (var i = 0; i < 5; i++) {
      Future.delayed(Duration(milliseconds: i * 80), () {
        if (mounted) setState(() => _stageVisible[i] = true);
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final agentName =
        ref.watch(agentFirstNameProvider(widget.orderId)).valueOrNull ??
        'Your agent';
    final garageAsync = ref.watch(garageDetailsProvider(widget.job.garageId));
    final garage = garageAsync.valueOrNull;
    final garageName = widget.job.garageNameCustom ?? garage?.name ?? '—';
    const activeColor = Color(0xFF185FA5);
    final estCompletion = widget.job.estimatedCompletion;
    final now = DateTime.now();
    final daysLeft = estCompletion != null && estCompletion.isAfter(now)
        ? estCompletion.difference(now).inDays
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F1FB),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: Row(
              children: [
                const Text('🔧', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        RepairConstants.state3HeroTitle,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: activeColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        estCompletion != null
                            ? (daysLeft != null && daysLeft >= 0
                                  ? '${RepairConstants.state3EstCompletionPrefix} ${_dateFormat.format(estCompletion)} · $daysLeft ${RepairConstants.state3DaysLeft}'
                                  : RepairConstants.state3FinishingUp)
                            : '—',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: activeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  RepairConstants.garageDetailsLabel,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 12),
                _GarageInfoRow(
                  label: RepairConstants.garageLabel,
                  value: garageName,
                ),
                _GarageInfoRow(
                  label: RepairConstants.locationLabel,
                  value: widget.job.garageLocation ?? '—',
                ),
                _GarageInfoRow(
                  label: RepairConstants.startedLabel,
                  value: widget.job.startDate != null
                      ? _dateFormat.format(widget.job.startDate!)
                      : '—',
                ),
                _GarageInfoRow(
                  label: RepairConstants.estCompletionShortLabel,
                  value: estCompletion != null
                      ? _dateFormat.format(estCompletion)
                      : '—',
                ),
                _GarageInfoRow(
                  label: RepairConstants.approvedQuoteLabel,
                  value: widget.job.totalQuotedGhs != null
                      ? CurrencyFormatter.formatGhs(widget.job.totalQuotedGhs!)
                      : '—',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _RepairTimelineStage(
            index: 0,
            label: RepairConstants.stageQuoteApproved,
            isDone: true,
            isActive: false,
            date: widget.job.quoteApprovedAt,
            visible: _stageVisible[0],
          ),
          _RepairTimelineStage(
            index: 1,
            label: RepairConstants.stageCarDropped,
            isDone: widget.job.startDate != null,
            isActive: false,
            date: widget.job.startDate,
            visible: _stageVisible[1],
          ),
          _RepairTimelineStage(
            index: 2,
            label: RepairConstants.stageWorkInProgress,
            isDone: widget.job.isCompleted,
            isActive: widget.job.isInProgress,
            date: null,
            visible: _stageVisible[2],
            pulseAnimation: _pulseController,
          ),
          _RepairTimelineStage(
            index: 3,
            label: RepairConstants.stageQualityCheck,
            isDone: false,
            isActive: false,
            date: null,
            visible: _stageVisible[3],
          ),
          _RepairTimelineStage(
            index: 4,
            label: RepairConstants.stageReadyForDelivery,
            isDone: false,
            isActive: false,
            date: null,
            visible: _stageVisible[4],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Text(
              RepairConstants.state3PhotoNote,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () => context.go('/order/${widget.orderId}?tab=chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
              child: Text(RepairConstants.askAgentButton(agentName)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _State4Complete extends ConsumerStatefulWidget {
  final String orderId;
  final RepairJob job;

  const _State4Complete({required this.orderId, required this.job});

  @override
  ConsumerState<_State4Complete> createState() => _State4CompleteState();
}

class _State4CompleteState extends ConsumerState<_State4Complete> {
  final List<bool> _sectionVisible = [false, false, false, false];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 4; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) setState(() => _sectionVisible[i] = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final agentName =
        ref.watch(agentFirstNameProvider(widget.orderId)).valueOrNull ??
        'Your agent';
    final order = ref.watch(orderProvider(widget.orderId)).valueOrNull;
    final makeModel = [
      order?.make,
      order?.model,
    ].whereType<String>().where((s) => s.isNotEmpty).join(' ');
    final displayMakeModel = makeModel.isEmpty ? 'vehicle' : makeModel;
    final allPhotos = [
      ...widget.job.beforePhotoUrls.map((u) => _PhotoItem(u, true)),
      ...widget.job.afterPhotoUrls.map((u) => _PhotoItem(u, false)),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          AnimatedOpacity(
            opacity: _sectionVisible[0] ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Transform.translate(
              offset: Offset(0, _sectionVisible[0] ? 0 : 12),
              child: _State4Hero(
                actualCompletion: widget.job.actualCompletion,
                makeModel: displayMakeModel,
              ),
            ),
          ),
          if (_sectionVisible[1]) ...[
            const SizedBox(height: 20),
            _State4PhotosRow(photos: allPhotos, jobId: widget.job.id),
          ],
          if (_sectionVisible[2]) ...[
            const SizedBox(height: 20),
            _State4WorkCard(job: widget.job),
          ],
          if (_sectionVisible[3]) ...[
            const SizedBox(height: 12),
            _State4DeliveryCard(orderId: widget.orderId, agentName: agentName),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _PhotoItem {
  final String url;
  final bool isBefore;

  _PhotoItem(this.url, this.isBefore);
}

class _State4Hero extends StatefulWidget {
  final DateTime? actualCompletion;
  final String makeModel;

  const _State4Hero({required this.actualCompletion, required this.makeModel});

  @override
  State<_State4Hero> createState() => _State4HeroState();
}

class _State4HeroState extends State<_State4Hero>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkController;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        children: [
          ScaleTransition(
            scale: CurvedAnimation(
              parent: _checkController,
              curve: Curves.easeOutBack,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 56,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            RepairConstants.state4HeroTitle,
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            RepairConstants.state4HeroSubtitle(widget.makeModel),
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          if (widget.actualCompletion != null) ...[
            const SizedBox(height: 4),
            Text(
              _dateFormat.format(widget.actualCompletion!),
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _State4PhotosRow extends StatelessWidget {
  final List<_PhotoItem> photos;
  final String jobId;

  const _State4PhotosRow({required this.photos, required this.jobId});

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 32,
              color: Colors.grey.shade500,
            ),
            const SizedBox(width: 12),
            Text(
              RepairConstants.state4PhotosPlaceholder,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      );
    }
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        itemBuilder: (context, i) {
          final item = photos[i];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _openPhotoViewer(context, photos, i, jobId),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: item.url,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Shimmer.fromColors(
                          baseColor: AppColors.surface,
                          highlightColor: Colors.white,
                          child: Container(color: AppColors.surface),
                        ),
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.danger,
                        ),
                      ),
                      Positioned(
                        left: 4,
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: item.isBefore
                                ? AppColors.surface
                                : const Color(0xFFEAF3DE),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.isBefore
                                ? RepairConstants.beforeLabel
                                : RepairConstants.afterLabel,
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              color: item.isBefore
                                  ? const Color(0xFF666666)
                                  : const Color(0xFF27500A),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openPhotoViewer(
    BuildContext context,
    List<_PhotoItem> photos,
    int initialIndex,
    String jobId,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (ctx) => _RepairPhotoViewer(
          photos: photos,
          initialIndex: initialIndex,
          jobId: jobId,
        ),
      ),
    );
  }
}

class _RepairPhotoViewer extends StatefulWidget {
  final List<_PhotoItem> photos;
  final int initialIndex;
  final String jobId;

  const _RepairPhotoViewer({
    required this.photos,
    required this.initialIndex,
    required this.jobId,
  });

  @override
  State<_RepairPhotoViewer> createState() => _RepairPhotoViewerState();
}

class _RepairPhotoViewerState extends State<_RepairPhotoViewer> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.photos.length,
            itemBuilder: (context, index) {
              final item = widget.photos[index];
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: item.url,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    errorWidget: (_, __, ___) => const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: Material(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(24),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _State4WorkCard extends StatelessWidget {
  final RepairJob job;

  const _State4WorkCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final totalPaid = job.finalCostGhs ?? job.totalQuotedGhs;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            RepairConstants.workCompletedLabel,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 12),
          if (job.workDescription != null && job.workDescription!.isNotEmpty)
            _DoneRow(label: job.workDescription!),
          if (job.platformServiceFeeGhs != null)
            _DoneRow(
              label:
                  '${RepairConstants.platformServiceFeeLabel} ${CurrencyFormatter.formatGhs(job.platformServiceFeeGhs!)}',
            ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                RepairConstants.totalPaidLabel,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                totalPaid != null
                    ? CurrencyFormatter.formatGhs(totalPaid)
                    : '—',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DoneRow extends StatelessWidget {
  final String label;

  const _DoneRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.dmSans(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            RepairConstants.doneLabel,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _State4DeliveryCard extends StatelessWidget {
  final String orderId;
  final String agentName;

  const _State4DeliveryCard({required this.orderId, required this.agentName});

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF185FA5);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F1FB),
        border: Border.all(color: const Color(0xFFB5D4F4)),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            RepairConstants.readyForDeliveryLabel,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: activeColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            RepairConstants.state4DeliveryBody(agentName),
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: activeColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: () => context.push('/order/$orderId/delivery'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
              child: Text(
                RepairConstants.confirmDeliveryButton,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _State5NoRepair extends ConsumerWidget {
  final String orderId;

  const _State5NoRepair({required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentName =
        ref.watch(agentFirstNameProvider(orderId)).valueOrNull ?? 'Your agent';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text('🚗', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 12),
                Text(
                  RepairConstants.state5Heading,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  RepairConstants.state5Body,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
                const Divider(height: 24),
                Text(
                  RepairConstants.state5AgentNote(agentName),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () => context.go('/order/$orderId?tab=chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
              child: Text(RepairConstants.askAgentButton(agentName)),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _showSwitchSheet(context, ref),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                RepairConstants.state5SwitchLink,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.75),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showSwitchSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                RepairConstants.switchSheetTitle,
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                RepairConstants.switchSheetBody,
                style: GoogleFonts.dmSans(fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text(RepairConstants.switchSheetCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        final result = await ref
                            .read(repairRepositoryProvider)
                            .switchToRepairs(orderId);
                        if (ctx.mounted) {
                          result.fold(
                            (_) => ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text(
                                  RepairConstants.writeErrorMessage,
                                ),
                              ),
                            ),
                            (_) {},
                          );
                        }
                      },
                      child: const Text(RepairConstants.switchSheetConfirm),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RepairTimelineStage extends StatelessWidget {
  final int index;
  final String label;
  final bool isDone;
  final bool isActive;
  final DateTime? date;
  final bool visible;
  final Animation<double>? pulseAnimation;

  const _RepairTimelineStage({
    required this.index,
    required this.label,
    required this.isDone,
    required this.isActive,
    required this.date,
    required this.visible,
    this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF185FA5);
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDone)
              const Icon(Icons.check_circle, color: AppColors.success, size: 20)
            else if (isActive && pulseAnimation != null)
              AnimatedBuilder(
                animation: pulseAnimation!,
                builder: (context, child) {
                  final t = Curves.easeInOut.transform(pulseAnimation!.value);
                  final scale = 1.0 + 0.4 * t;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: activeColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              )
            else
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.2),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
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
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isActive
                          ? activeColor
                          : isDone
                          ? null
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  if (date != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _dateFormat.format(date!),
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StateAwaitingQuote extends ConsumerWidget {
  final String orderId;

  const _StateAwaitingQuote({required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentName =
        ref.watch(agentFirstNameProvider(orderId)).valueOrNull ?? 'Your agent';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F1FB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFB5D4F4)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.build_outlined,
                  size: 40,
                  color: Color(0xFF185FA5),
                ),
                const SizedBox(height: 12),
                Text(
                  'Waiting for garage quote',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF185FA5),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$agentName has been notified and will send '
                  'you a garage quote shortly. You will be '
                  'notified when it arrives.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: const Color(0xFF185FA5),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () => context.go('/order/$orderId?tab=chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF378ADD),
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Chat with $agentName →',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
