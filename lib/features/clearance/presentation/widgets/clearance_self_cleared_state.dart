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
import 'clearance_always_one_animation.dart';
import 'clearance_arrival_bar.dart';
import 'clearance_info_row.dart';

class ClearanceSelfClearedState extends ConsumerStatefulWidget {
  const ClearanceSelfClearedState({
    super.key,
    required this.orderId,
    required this.shipping,
  });

  final String orderId;
  final Shipping shipping;

  @override
  ConsumerState<ClearanceSelfClearedState> createState() =>
      _ClearanceSelfClearedStateState();
}

class _ClearanceSelfClearedStateState
    extends ConsumerState<ClearanceSelfClearedState> {
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
                style: AppTextStyles.titleSmall.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                ClearanceConstants.switchSheetBody(feeFormatted),
                style: AppTextStyles.bodySmall,
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
                        final feeUsd =
                            ref.read(clearanceServiceFeeProvider).valueOrNull ??
                            ClearanceConstants.clearanceFeeFallbackUsd;
                        final result = await repo.switchToAgentClearance(
                          orderId: orderId,
                          clearanceFeeUsd: feeUsd,
                        );
                        if (ctx.mounted) {
                          result.fold(
                            (_) => ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ClearanceConstants.writeErrorMessage,
                                ),
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

  @override
  Widget build(BuildContext context) {
    final agentName =
        ref.watch(agentFirstNameProvider(widget.orderId)).valueOrNull ??
        'Your agent';
    final feeAsync = ref.watch(clearanceServiceFeeProvider);
    final preferredCurrency = ref.watch(preferredCurrencyProvider);
    final feeUsd =
        feeAsync.valueOrNull ?? ClearanceConstants.clearanceFeeFallbackUsd;
    final feeFormatted = CurrencyFormatter.formatForDisplay(
      usdAmount: feeUsd,
      preferredCurrency: preferredCurrency,
    ).primary;

    return SingleChildScrollView(
      padding: DashboardLayout.flowScrollPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          ClearanceArrivalBar(
            animation: const ClearanceAlwaysOneAnimation(),
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
                  style: AppTextStyles.titleSmall.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  ClearanceConstants.state3Body,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(height: 1.6),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                ClearanceInfoRow(
                  icon: '📋',
                  text: ClearanceConstants.state3Row1,
                  visible: _rowVisible[0],
                ),
                ClearanceInfoRow(
                  icon: '🏦',
                  text: ClearanceConstants.state3Row2,
                  visible: _rowVisible[1],
                ),
                ClearanceInfoRow(
                  icon: '🚢',
                  text: ClearanceConstants.state3Row3,
                  visible: _rowVisible[2],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.infoBackground,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ClearanceConstants.state3NeedHelp,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.infoText,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$agentName ${ClearanceConstants.state3AgentHelpBodySuffix}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.infoText,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () =>
                        context.go('/order/${widget.orderId}?tab=chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child: Text(
                      ClearanceConstants.state3AskAgentButton(agentName),
                      style: AppTextStyles.buttonLarge.copyWith(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: () =>
                _showSwitchSheet(context, ref, widget.orderId, feeFormatted),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                ClearanceConstants.state3SwitchLink,
                style: AppTextStyles.link.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  decorationColor: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
