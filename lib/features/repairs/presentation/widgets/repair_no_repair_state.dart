import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../core/constants/repair_constants.dart';
import '../../../clearance/presentation/providers/clearance_providers.dart';
import '../providers/repair_providers.dart';
import 'repair_navigation.dart';

class RepairNoRepairState extends ConsumerWidget {
  const RepairNoRepairState({
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
                  style: AppTextStyles.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  RepairConstants.state5Body,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
                const Divider(height: 24),
                Text(
                  RepairConstants.state5AgentNote(agentName),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.cardLabel.copyWith(
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
              onPressed: repairScreenChatTap(context, orderId, onOpenChat),
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
                style: AppTextStyles.cardLabel.copyWith(
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
                style: AppTextStyles.titleMedium.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                RepairConstants.switchSheetBody,
                style: AppTextStyles.bodyMedium,
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
