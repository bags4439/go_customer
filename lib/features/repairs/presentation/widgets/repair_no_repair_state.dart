import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../core/constants/repair_constants.dart';
import '../../../clearance/presentation/providers/clearance_providers.dart';
import '../providers/repair_providers.dart';
import 'repair_navigation.dart';

class RepairNoRepairState extends ConsumerStatefulWidget {
  const RepairNoRepairState({
    super.key,
    required this.orderId,
    this.onOpenChat,
  });

  final String orderId;
  final VoidCallback? onOpenChat;

  @override
  ConsumerState<RepairNoRepairState> createState() =>
      _RepairNoRepairStateState();
}

class _RepairNoRepairStateState extends ConsumerState<RepairNoRepairState> {
  void _showSwitchSheet(BuildContext context) {
    var switching = false;
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (ctx, setSheetState) => SafeArea(
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
                        onPressed: switching
                            ? null
                            : () => Navigator.of(sheetContext).pop(),
                        child: const Text(RepairConstants.switchSheetCancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: switching
                            ? null
                            : () async {
                                setSheetState(() => switching = true);
                                final result = await ref
                                    .read(repairRepositoryProvider)
                                    .switchToRepairs(widget.orderId);
                                if (!context.mounted) return;
                                result.fold(
                                  (_) {
                                    setSheetState(() => switching = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          RepairConstants.writeErrorMessage,
                                        ),
                                      ),
                                    );
                                  },
                                  (_) => Navigator.of(sheetContext).pop(),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                        ),
                        child: switching
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(RepairConstants.switchSheetConfirm),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
              onPressed: repairScreenChatTap(
                context,
                widget.orderId,
                widget.onOpenChat,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
              child: Text(RepairConstants.askAgentButton(agentName)),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _showSwitchSheet(context),
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
}
