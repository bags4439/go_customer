import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/layout/dashboard_layout.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/providers/preferred_currency_provider.dart';
import '../../../shipping/domain/entities/shipping.dart';
import '../../core/constants/clearance_constants.dart';
import '../providers/clearance_providers.dart';
import 'clearance_arrival_bar.dart';
import 'clearance_confirm_button.dart';
import 'clearance_option_card.dart';

class ClearanceChoiceState extends ConsumerStatefulWidget {
  const ClearanceChoiceState({
    super.key,
    required this.orderId,
    required this.shipping,
  });

  final String orderId;
  final Shipping shipping;

  @override
  ConsumerState<ClearanceChoiceState> createState() =>
      _ClearanceChoiceStateState();
}

class _ClearanceChoiceStateState extends ConsumerState<ClearanceChoiceState>
    with SingleTickerProviderStateMixin {
  late AnimationController _arrivalController;

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
    final option = ref
        .read(selectedClearanceOptionProvider(widget.orderId).notifier)
        .state;
    if (option == null) return;
    if (ref.read(clearanceChoiceSubmittingProvider(widget.orderId))) return;

    final submitting =
        ref.read(clearanceChoiceSubmittingProvider(widget.orderId).notifier);
    submitting.state = true;

    final repo = ref.read(dutyClearanceRepositoryProvider);
    final feeUsdAsync = ref.read(clearanceServiceFeeProvider);
    final feeUsd =
        feeUsdAsync.valueOrNull ?? ClearanceConstants.clearanceFeeFallbackUsd;

    try {
      final result = option == ClearanceOption.agentHandles
          ? await repo.confirmAgentClearance(
              orderId: widget.orderId,
              clearanceFeeUsd: feeUsd,
            )
          : await repo.confirmSelfClearance(widget.orderId);
      if (!mounted) return;
      result.fold(
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ClearanceConstants.writeErrorMessage)),
          );
        },
        (_) {},
      );
    } finally {
      if (mounted) {
        submitting.state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final option = ref.watch(selectedClearanceOptionProvider(widget.orderId));
    final isSubmitting =
        ref.watch(clearanceChoiceSubmittingProvider(widget.orderId));
    final feeAsync = ref.watch(clearanceServiceFeeProvider);
    final preferredCurrency = ref.watch(preferredCurrencyProvider);
    final agentName =
        ref.watch(agentFirstNameProvider(widget.orderId)).valueOrNull ??
        'Your agent';
    final feeUsd = feeAsync.valueOrNull;
    final feeFormatted = (feeUsd != null)
        ? CurrencyFormatter.formatForDisplay(
            usdAmount: feeUsd,
            preferredCurrency: preferredCurrency,
          ).primary
        : null;

    return SingleChildScrollView(
      padding: DashboardLayout.flowScrollPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          ClearanceArrivalBar(
            animation: _arrivalController,
            arrivalDate: widget.shipping.actualArrival,
          ),
          const SizedBox(height: 24),
          Text(
            ClearanceConstants.state1Heading,
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            ClearanceConstants.state1Subtitle,
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 16),
          ClearanceOptionCard(
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
            iconBgColor: AppColors.infoBackground,
            iconData: Icons.person,
          ),
          const SizedBox(height: 12),
          ClearanceOptionCard(
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
                  style: AppTextStyles.cardLabel,
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => context.go('/order/${widget.orderId}?tab=chat'),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      ClearanceConstants.askAgentLink(agentName),
                      style: AppTextStyles.link,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ClearanceConfirmButton(
            option: option,
            isSubmitting: isSubmitting,
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
