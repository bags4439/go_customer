import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../core/constants/repair_constants.dart';
import '../../../clearance/presentation/providers/clearance_providers.dart';
import 'repair_navigation.dart';

class RepairAwaitingQuoteState extends ConsumerWidget {
  const RepairAwaitingQuoteState({
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.infoBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFB5D4F4)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.build_outlined,
                  size: 40,
                  color: AppColors.infoText,
                ),
                const SizedBox(height: 12),
                Text(
                  RepairConstants.awaitingQuoteTitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.infoText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  RepairConstants.awaitingQuoteBody(agentName),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.infoText,
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
              onPressed: repairScreenChatTap(context, orderId, onOpenChat),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
              child: Text(
                RepairConstants.chatWithAgentButton(agentName),
                style: AppTextStyles.buttonMedium.copyWith(
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
