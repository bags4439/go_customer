import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/layout/dashboard_layout.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../core/constants/repair_constants.dart';
import '../../../clearance/presentation/providers/clearance_providers.dart';
import 'repair_navigation.dart';
import 'repair_pulsing_dots.dart';

class RepairQuoteDeclinedState extends ConsumerWidget {
  const RepairQuoteDeclinedState({
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
      padding: DashboardLayout.flowOuterPaddingAll(context),
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
                  style: AppTextStyles.titleSmall.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  RepairConstants.state2BBody(agentName),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const RepairPulsingDots(),
          const SizedBox(height: 32),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: repairScreenChatTap(context, orderId, onOpenChat),
              child: Text(RepairConstants.askAgentButton(agentName)),
            ),
          ),
        ],
      ),
    );
  }
}
