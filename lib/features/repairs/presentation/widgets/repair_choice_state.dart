import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/currency_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../core/constants/repair_constants.dart';
import '../../../clearance/presentation/providers/clearance_providers.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../providers/repair_providers.dart';
import 'repair_cleared_bar.dart';
import 'repair_confirm_button.dart';
import 'repair_option_card.dart';

class RepairChoiceState extends ConsumerStatefulWidget {
  const RepairChoiceState({
    super.key,
    required this.orderId,
    required this.dutyClearedAt,
    required this.currency,
  });

  final String orderId;
  final DateTime? dutyClearedAt;
  final CurrencyModel currency;

  @override
  ConsumerState<RepairChoiceState> createState() => _RepairChoiceStateState();
}

class _RepairChoiceStateState extends ConsumerState<RepairChoiceState>
    with SingleTickerProviderStateMixin {
  late AnimationController _clearedBarController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _clearedBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefillChoiceFromOrder());
  }

  void _prefillChoiceFromOrder() {
    if (!mounted) return;
    final current = ref.read(repairChoiceProvider(widget.orderId));
    if (current != null) return;
    final order = ref.read(orderProvider(widget.orderId)).valueOrNull;
    if (order == null) return;
    ref.read(repairChoiceProvider(widget.orderId).notifier).state =
        order.repairOptedIn;
  }

  @override
  void dispose() {
    _clearedBarController.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    final choice = ref.read(repairChoiceProvider(widget.orderId).notifier).state;
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

  @override
  Widget build(BuildContext context) {
    final choice = ref.watch(repairChoiceProvider(widget.orderId));
    final order = ref.watch(orderProvider(widget.orderId)).valueOrNull;
    final agentName =
        ref.watch(agentFirstNameProvider(widget.orderId)).valueOrNull ??
        'Your agent';
    final estimateAsync = ref.watch(repairEstimateProvider(widget.orderId));
    final estimateGhs = estimateAsync.valueOrNull;
    final estimateStr = estimateGhs != null
        ? '~${CurrencyFormatter.formatGhsForDisplay(
            amountGhs: estimateGhs,
            preferredCurrency: widget.currency,
          ).primary}'
        : RepairConstants.estVaries;
    final repairFeeAsync = ref.watch(repairServiceFeeProvider);
    final repairFeeUsd =
        repairFeeAsync.valueOrNull ?? RepairConstants.repairFeeFallbackUsd;
    final repairFeeDisplay = repairFeeUsd > 0
        ? CurrencyFormatter.formatForDisplay(
            usdAmount: repairFeeUsd,
            preferredCurrency: widget.currency,
          )
        : null;
    final preferenceReminder = order == null
        ? null
        : order.repairOptedIn
            ? RepairConstants.reminderOptedIn
            : RepairConstants.reminderOptedOut;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          RepairClearedBar(
            animation: _clearedBarController,
            clearedAt: widget.dutyClearedAt,
          ),
          if (preferenceReminder != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.infoBackground,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                preferenceReminder,
                style: AppTextStyles.cardLabel.copyWith(height: 1.5),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            RepairConstants.state1Heading,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          RepairOptionCard(
            orderId: widget.orderId,
            isYes: true,
            isSelected: choice == true,
            estimateLabel: estimateStr,
            agentFirstName: agentName,
            coordinationFeeDisplay: repairFeeDisplay,
          ),
          const SizedBox(height: 12),
          RepairOptionCard(
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
                  style: AppTextStyles.cardLabel.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          RepairConfirmButton(
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
