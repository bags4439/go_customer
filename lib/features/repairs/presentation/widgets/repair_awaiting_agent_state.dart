import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/layout/dashboard_layout.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../core/constants/repair_constants.dart';
import '../../../clearance/presentation/providers/clearance_providers.dart';
import 'repair_navigation.dart';

/// Shown when the order is on the repair stage but the agent has not yet
/// created a repair job — routing is agent-driven after clearance.
class RepairAwaitingAgentState extends ConsumerWidget {
  const RepairAwaitingAgentState({
    super.key,
    required this.orderId,
    this.onOpenChat,
  });

  final String orderId;
  final VoidCallback? onOpenChat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentName =
        ref.watch(agentFirstNameProvider(orderId)).valueOrNull ?? 'Your agent';

    return SingleChildScrollView(
      padding: DashboardLayout.flowScrollPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.infoBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.engineering_outlined,
                  size: 44,
                  color: AppColors.infoText,
                ),
                const SizedBox(height: 14),
                Text(
                  RepairConstants.awaitingAgentTitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.infoText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  RepairConstants.awaitingAgentBody(agentName),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Text(
              RepairConstants.awaitingAgentHint,
              style: AppTextStyles.cardLabel.copyWith(height: 1.5),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: repairScreenChatTap(context, orderId, onOpenChat),
              child: Text(
                RepairConstants.chatWithAgentButton(agentName),
                style: AppTextStyles.buttonMedium.copyWith(
                  fontWeight: FontWeight.w500,
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
