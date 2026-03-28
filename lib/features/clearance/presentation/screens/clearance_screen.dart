import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../core/constants/clearance_constants.dart';
import '../../domain/entities/duty_clearance.dart';
import '../../../shipping/domain/entities/shipping.dart';
import '../../../shipping/presentation/providers/shipping_providers.dart';
import '../providers/clearance_providers.dart';

final _arrivalDateFormat = DateFormat('d MMMM yyyy');

class ClearanceScreen extends ConsumerWidget {
  final String orderId;

  const ClearanceScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenState = ref.watch(clearanceScreenStateProvider(orderId));
    final shippingAsync = ref.watch(shippingProvider(orderId));
    final dutyAsync = ref.watch(dutyClearanceProvider(orderId));

    print('clearance: ${screenState.name}');

    final isLoading = shippingAsync.isLoading || dutyAsync.isLoading;
    final hasError = shippingAsync.hasError || dutyAsync.hasError;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
          style: IconButton.styleFrom(
            minimumSize: const Size(48, 48),
          ),
        ),
        title: Text(
          'Clearance',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      body: hasError
          ? _ClearanceErrorCard(
              orderId: orderId,
              onRetry: () {
                ref.invalidate(shippingProvider(orderId));
                ref.invalidate(dutyClearanceProvider(orderId));
              },
            )
          : isLoading
              ? const _ClearanceLoadingBody()
              : _ClearanceBody(
                  orderId: orderId,
                  screenState: screenState,
                  shipping: shippingAsync.valueOrNull,
                  duty: dutyAsync.valueOrNull,
                ),
    );
  }
}

class _ClearanceErrorCard extends StatelessWidget {
  final String orderId;
  final VoidCallback onRetry;

  const _ClearanceErrorCard({
    required this.orderId,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.danger,
            ),
            const SizedBox(height: 16),
            Text(
              ClearanceConstants.errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.primary,
                  ),
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

class _ClearanceLoadingBody extends StatelessWidget {
  const _ClearanceLoadingBody();

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
              height: 120,
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
              height: 120,
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

class _ClearanceBody extends StatelessWidget {
  final String orderId;
  final ClearanceScreenState screenState;
  final Shipping? shipping;
  final DutyClearance? duty;

  const _ClearanceBody({
    required this.orderId,
    required this.screenState,
    required this.shipping,
    required this.duty,
  });

  @override
  Widget build(BuildContext context) {
    switch (screenState) {
      case ClearanceScreenState.notAvailable:
        return _State0NotAvailable(orderId: orderId);
      case ClearanceScreenState.choicePending:
        return _State1Choice(
          orderId: orderId,
          shipping: shipping!,
        );
      case ClearanceScreenState.agentManaged:
        return _State2AgentManaged(
          orderId: orderId,
          shipping: shipping!,
          duty: duty!,
        );
      case ClearanceScreenState.selfCleared:
        return _State3SelfCleared(
          orderId: orderId,
          shipping: shipping!,
        );
    }
  }
}

class _State0NotAvailable extends StatelessWidget {
  final String orderId;

  const _State0NotAvailable({required this.orderId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_boat_outlined,
              size: 80,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 24),
            Text(
              ClearanceConstants.state0Heading,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              ClearanceConstants.state0Body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: () => context.go('/order/$orderId'),
                child: const Text(ClearanceConstants.state0BackButton),
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
  final Shipping shipping;

  const _State1Choice({required this.orderId, required this.shipping});

  @override
  ConsumerState<_State1Choice> createState() => _State1ChoiceState();
}

class _State1ChoiceState extends ConsumerState<_State1Choice>
    with SingleTickerProviderStateMixin {
  late AnimationController _arrivalController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _arrivalController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _arrivalController.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    final option = ref.read(selectedClearanceOptionProvider(widget.orderId).notifier).state;
    if (option == null || _isSubmitting) return;
    final repo = ref.read(dutyClearanceRepositoryProvider);
    final feeAsync = ref.read(clearanceServiceFeeProvider);
    final fee = feeAsync.valueOrNull ?? ClearanceConstants.clearanceFeeFallbackGhs;

    setState(() => _isSubmitting = true);
    final result = option == ClearanceOption.agentHandles
        ? await repo.confirmAgentClearance(
            orderId: widget.orderId,
            clearanceFeeGhs: fee,
          )
        : await repo.confirmSelfClearance(widget.orderId);
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    result.fold(
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ClearanceConstants.writeErrorMessage)),
        );
      },
      (_) {
        // Stream update will transition to State 2 or State 3 automatically
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final option = ref.watch(selectedClearanceOptionProvider(widget.orderId));
    final feeAsync = ref.watch(clearanceServiceFeeProvider);
    final agentName = ref.watch(agentFirstNameProvider(widget.orderId)).valueOrNull ?? 'Your agent';
    final fee = feeAsync.valueOrNull;
    final feeFormatted = fee != null ? CurrencyFormatter.formatGhs(fee) : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          _ArrivalBar(
            animation: _arrivalController,
            arrivalDate: widget.shipping.actualArrival,
          ),
          const SizedBox(height: 24),
          Text(
            ClearanceConstants.state1Heading,
            style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            ClearanceConstants.state1Subtitle,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 16),
          _OptionCard(
            orderId: widget.orderId,
            type: ClearanceOption.agentHandles,
            isSelected: option == ClearanceOption.agentHandles,
            agentFirstName: agentName,
            priceLabel: feeFormatted,
            priceSubLabel: ClearanceConstants.optionAgentPriceLabel,
            bullets: [
              ClearanceConstants.optionAgentBullet1(agentName),
              ClearanceConstants.optionAgentBullet2,
              ClearanceConstants.optionAgentBullet3,
              ClearanceConstants.optionAgentBullet4,
            ],
            iconBgColor: const Color(0xFFE6F1FB),
            iconData: Icons.person,
          ),
          const SizedBox(height: 12),
          _OptionCard(
            orderId: widget.orderId,
            type: ClearanceOption.selfClearance,
            isSelected: option == ClearanceOption.selfClearance,
            agentFirstName: agentName,
            priceLabel: ClearanceConstants.optionSelfPrice,
            priceSubLabel: ClearanceConstants.optionSelfPriceLabel,
            bullets: [
              ClearanceConstants.optionSelfBullet1,
              ClearanceConstants.optionSelfBullet2,
              '$agentName ${ClearanceConstants.optionSelfBullet3Suffix}',
            ],
            iconBgColor: AppColors.surface,
            iconData: Icons.person_outline,
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
                  ClearanceConstants.notSureHeading,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => context.go('/order/${widget.orderId}?tab=chat'),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      ClearanceConstants.askAgentLink(agentName),
                      style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.secondary,
                            decoration: TextDecoration.underline,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _ConfirmButton(
            option: option,
            isSubmitting: _isSubmitting,
            onConfirm: _onConfirm,
            label: option == ClearanceOption.agentHandles
                ? ClearanceConstants.confirmAgentButton
                : option == ClearanceOption.selfClearance
                    ? ClearanceConstants.confirmSelfButton
                    : ClearanceConstants.confirmButtonSelectOption,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ArrivalBar extends StatelessWidget {
  final Animation<double> animation;
  final DateTime? arrivalDate;

  const _ArrivalBar({required this.animation, this.arrivalDate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                    ClearanceConstants.arrivalBarTitle,
                    style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: const Color(0xFF27500A),
                        ),
                  ),
                  if (arrivalDate != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _arrivalDateFormat.format(arrivalDate!),
                      style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: const Color(0xFF3B6D11),
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

class _OptionCard extends ConsumerWidget {
  final String orderId;
  final ClearanceOption type;
  final bool isSelected;
  final String agentFirstName;
  final String? priceLabel;
  final String priceSubLabel;
  final List<String> bullets;
  final Color iconBgColor;
  final IconData iconData;

  const _OptionCard({
    required this.orderId,
    required this.type,
    required this.isSelected,
    required this.agentFirstName,
    required this.priceLabel,
    required this.priceSubLabel,
    required this.bullets,
    required this.iconBgColor,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notifier = ref.read(selectedClearanceOptionProvider(orderId).notifier);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => notifier.state = type,
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
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconData, size: 22, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type == ClearanceOption.agentHandles
                              ? ClearanceConstants.optionAgentTitle
                              : ClearanceConstants.optionSelfTitle,
                          style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                color: isSelected ? AppColors.secondary : null,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (priceLabel != null)
                              Text(
                                priceLabel!,
                                style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: type == ClearanceOption.selfClearance
                                          ? AppColors.success
                                          : null,
                                    ),
                              ),
                            const SizedBox(width: 4),
                            Text(
                              priceSubLabel,
                              style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 10,
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
                      color: isSelected ? AppColors.secondary : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? AppColors.secondary : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ],
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: bullets
                          .map(
                            (b) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '• ',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  Expanded(child: Text(b, style: theme.textTheme.bodySmall)),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                crossFadeState:
                    isSelected ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final ClearanceOption? option;
  final bool isSubmitting;
  final VoidCallback onConfirm;
  final String label;

  const _ConfirmButton({
    required this.option,
    required this.isSubmitting,
    required this.onConfirm,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = option != null && !isSubmitting;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      height: 48,
      child: ElevatedButton(
        onPressed: enabled ? onConfirm : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? AppColors.secondary : AppColors.surface,
          foregroundColor: enabled ? Colors.white : AppColors.primary.withValues(alpha: 0.6),
          disabledBackgroundColor: AppColors.surface,
          disabledForegroundColor: AppColors.primary.withValues(alpha: 0.5),
        ),
        child: isSubmitting
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}

class _State2AgentManaged extends ConsumerStatefulWidget {
  final String orderId;
  final Shipping shipping;
  final DutyClearance duty;

  const _State2AgentManaged({
    required this.orderId,
    required this.shipping,
    required this.duty,
  });

  @override
  ConsumerState<_State2AgentManaged> createState() => _State2AgentManagedState();
}

class _State2AgentManagedState extends ConsumerState<_State2AgentManaged>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  final List<bool> _stageVisible = [false, false, false, false];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    for (var i = 0; i < 4; i++) {
      Future.delayed(Duration(milliseconds: i * 80), () {
        if (mounted) {
          setState(() => _stageVisible[i] = true);
        }
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
    final theme = Theme.of(context);
    final agentName = ref.watch(agentFirstNameProvider(widget.orderId)).valueOrNull ?? 'Your agent';
    final graStatus = widget.duty.graStatus;
    final hasDetails = widget.duty.icumsRef != null ||
        widget.duty.clearingAgentName != null ||
        widget.duty.totalPayableGhs != null ||
        (widget.duty.notes != null && widget.duty.notes!.isNotEmpty);
    const activeColor = Color(0xFF185FA5);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          _ArrivalBar(
            animation: const _AlwaysOneAnimation(),
            arrivalDate: widget.shipping.actualArrival,
          ),
          const SizedBox(height: 24),
          _TimelineStageRow(
            index: 0,
            label: ClearanceConstants.stage2Arrived,
            isDone: true,
            isActive: false,
            date: widget.shipping.actualArrival,
            visible: _stageVisible[0],
          ),
          _TimelineStageRow(
            index: 1,
            label: ClearanceConstants.stage2Assessed,
            isDone: graStatus == 'assessed' || graStatus == 'paid' || graStatus == 'cleared',
            isActive: graStatus == 'submitted',
            date: widget.duty.assessedAt,
            visible: _stageVisible[1],
            pulseAnimation: _pulseController,
          ),
          _TimelineStageRow(
            index: 2,
            label: ClearanceConstants.stage2DutyPaid,
            isDone: graStatus == 'paid' || graStatus == 'cleared',
            isActive: graStatus == 'assessed',
            date: widget.duty.paidAt,
            visible: _stageVisible[2],
            pulseAnimation: _pulseController,
          ),
          _TimelineStageRow(
            index: 3,
            label: ClearanceConstants.stage2Cleared,
            isDone: graStatus == 'cleared',
            isActive: graStatus == 'paid',
            date: widget.duty.clearedAt,
            visible: _stageVisible[3],
            pulseAnimation: _pulseController,
          ),
          if (hasDetails) ...[
            const SizedBox(height: 20),
            _DetailsCard(duty: widget.duty),
          ],
          if (graStatus == 'assessed') ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F1FB),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Text(
                ClearanceConstants.state2AssessedNote,
                style: theme.textTheme.bodySmall?.copyWith(
                      color: activeColor,
                      fontSize: 12,
                    ),
              ),
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () => context.go('/order/${widget.orderId}?tab=chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
              child: Text(ClearanceConstants.askAgentButton(agentName)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _AlwaysOneAnimation extends Animation<double> {
  const _AlwaysOneAnimation();
  @override
  double get value => 1.0;
  @override
  void addListener(VoidCallback listener) {}
  @override
  void removeListener(VoidCallback listener) {}
  @override
  void addStatusListener(AnimationStatusListener listener) {}
  @override
  void removeStatusListener(AnimationStatusListener listener) {}
  @override
  AnimationStatus get status => AnimationStatus.completed;
}

class _TimelineStageRow extends StatelessWidget {
  final int index;
  final String label;
  final bool isDone;
  final bool isActive;
  final DateTime? date;
  final bool visible;
  final Animation<double>? pulseAnimation;

  const _TimelineStageRow({
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
    final theme = Theme.of(context);
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
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
                    style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isActive ? activeColor : (isDone ? null : theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                        ),
                  ),
                  if (date != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _arrivalDateFormat.format(date!),
                      style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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

class _DetailsCard extends StatelessWidget {
  final DutyClearance duty;

  const _DetailsCard({required this.duty});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(
            label: ClearanceConstants.detailsCardIcumsLabel,
            value: duty.icumsRef ?? ClearanceConstants.detailsCardPending,
            textTheme: textTheme,
          ),
          _DetailRow(
            label: ClearanceConstants.detailsCardClearingAgentLabel,
            value: duty.clearingAgentName ?? ClearanceConstants.detailsCardPending,
            textTheme: textTheme,
          ),
          _DetailRow(
            label: ClearanceConstants.detailsCardTotalDutyLabel,
            value: duty.totalPayableGhs != null
                ? CurrencyFormatter.formatGhs(duty.totalPayableGhs!)
                : '—',
            textTheme: textTheme,
          ),
          if (duty.notes != null && duty.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              ClearanceConstants.detailsCardAgentNoteLabel,
              style: textTheme.labelSmall,
            ),
            const SizedBox(height: 2),
            Text(duty.notes!, style: textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final TextTheme textTheme;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: textTheme.bodySmall),
          ),
          Expanded(child: Text(value, style: textTheme.bodySmall)),
        ],
      ),
    );
  }
}

class _State3SelfCleared extends ConsumerStatefulWidget {
  final String orderId;
  final Shipping shipping;

  const _State3SelfCleared({required this.orderId, required this.shipping});

  @override
  ConsumerState<_State3SelfCleared> createState() => _State3SelfClearedState();
}

class _State3SelfClearedState extends ConsumerState<_State3SelfCleared> {
  final List<bool> _rowVisible = [false, false, false];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 60), () {
        if (mounted) setState(() => _rowVisible[i] = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final agentName = ref.watch(agentFirstNameProvider(widget.orderId)).valueOrNull ?? 'Your agent';
    final feeAsync = ref.watch(clearanceServiceFeeProvider);
    final fee = feeAsync.valueOrNull ?? ClearanceConstants.clearanceFeeFallbackGhs;
    final feeFormatted = CurrencyFormatter.formatGhs(fee);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          _ArrivalBar(
            animation: const _AlwaysOneAnimation(),
            arrivalDate: widget.shipping.actualArrival,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                const Text('🙋', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 12),
                Text(
                  ClearanceConstants.state3Heading,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  ClearanceConstants.state3Body,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        height: 1.6,
                      ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: '📋',
                  text: ClearanceConstants.state3Row1,
                  visible: _rowVisible[0],
                  theme: theme,
                ),
                _InfoRow(
                  icon: '🏦',
                  text: ClearanceConstants.state3Row2,
                  visible: _rowVisible[1],
                  theme: theme,
                ),
                _InfoRow(
                  icon: '🚢',
                  text: ClearanceConstants.state3Row3,
                  visible: _rowVisible[2],
                  theme: theme,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F1FB),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ClearanceConstants.state3NeedHelp,
                  style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                        color: const Color(0xFF185FA5),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$agentName ${ClearanceConstants.state3AgentHelpBodySuffix}',
                  style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: const Color(0xFF185FA5),
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => context.go('/order/${widget.orderId}?tab=chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      ClearanceConstants.state3AskAgentButton(agentName),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: () => _showSwitchSheet(context, ref, widget.orderId, feeFormatted),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                ClearanceConstants.state3SwitchLink,
                style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
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

  void _showSwitchSheet(
    BuildContext context,
    WidgetRef ref,
    String orderId,
    String feeFormatted,
  ) {
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
                ClearanceConstants.switchSheetTitle,
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                ClearanceConstants.switchSheetBody(feeFormatted),
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text(ClearanceConstants.switchSheetCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        final repo = ref.read(dutyClearanceRepositoryProvider);
                        final fee = ref.read(clearanceServiceFeeProvider).valueOrNull ??
                            ClearanceConstants.clearanceFeeFallbackGhs;
                        final result = await repo.switchToAgentClearance(
                          orderId: orderId,
                          clearanceFeeGhs: fee,
                        );
                        if (ctx.mounted) {
                          result.fold(
                            (_) => ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(
                                    content: Text(ClearanceConstants.writeErrorMessage),
                                  ),
                                ),
                            (_) {},
                          );
                        }
                      },
                      child: const Text(ClearanceConstants.switchSheetConfirm),
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

class _InfoRow extends StatelessWidget {
  final String icon;
  final String text;
  final bool visible;
  final ThemeData theme;

  const _InfoRow({
    required this.icon,
    required this.text,
    required this.visible,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
