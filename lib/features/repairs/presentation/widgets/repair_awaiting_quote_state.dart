import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_text_styles.dart';
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
                  style: AppTextStyles.titleSmall.copyWith(
                    color: const Color(0xFF185FA5),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$agentName has been notified and will send '
                  'you a garage quote shortly. You will be '
                  'notified when it arrives.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
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
              onPressed: repairScreenChatTap(context, orderId, onOpenChat),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF378ADD),
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Chat with $agentName →',
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
