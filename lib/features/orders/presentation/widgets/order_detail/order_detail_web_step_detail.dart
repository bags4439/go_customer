import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';

import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/features/orders/data/models/order_timeline_model.dart';
import 'package:go_customer/features/orders/domain/entities/order_view.dart';
import 'package:go_customer/features/orders/presentation/providers/order_providers.dart';
import 'package:go_customer/features/orders/presentation/providers/order_timeline_providers.dart';
import 'package:go_customer/features/orders/presentation/widgets/order_timeline_step_row.dart';

class OrderDetailWebStepDetail extends ConsumerWidget {
  const OrderDetailWebStepDetail({
    super.key,
    required this.orderId,
    required this.order,
    required this.stageKey,
    required this.onBack,
  });

  final String orderId;
  final OrderView? order;
  final String stageKey;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingPaymentRequestsProvider(orderId));
    final shippingAsync = ref.watch(orderShippingProvider(orderId));
    final clearanceAsync = ref.watch(orderClearanceProvider(orderId));
    final repairAsync = ref.watch(orderRepairJobProvider(orderId));
    final timelineAsync = ref.watch(orderTimelineProvider(orderId));

    final pending = pendingAsync.valueOrNull ?? [];
    final shipping = shippingAsync.valueOrNull;
    final clearance = clearanceAsync.valueOrNull;
    final repairJob = repairAsync.valueOrNull;
    final stages = timelineAsync.valueOrNull ?? [];

    OrderTimelineModel? stage;
    for (final s in stages) {
      if (s.stageKey == stageKey) {
        stage = s;
        break;
      }
    }
    final stageLabel = stage?.label ?? stageKey;

    final Widget stageContent;
    if (order == null || stage == null) {
      stageContent = Text(
        'No additional details for this stage.',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
      );
    } else {
      stageContent = OrderTimelineSubActionArea(
        stage: stage,
        orderId: orderId,
        order: order!,
        pendingPayments: pending,
        shipping: shipping,
        clearance: clearance,
        repairJob: repairJob,
        onChatTap: () => context.go('/order/$orderId?tab=chat'),
      );
    }

    final agentId = order?.agentId;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onBack,
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Back to agent',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: AppColors.amberBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              stageLabel,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.amberText,
              ),
            ),
          ),
          const SizedBox(height: 14),
          stageContent,
          const SizedBox(height: 16),
          Container(height: .5, color: AppColors.borderSolid),
          const SizedBox(height: 12),
          if (agentId != null)
            Builder(
              builder: (context) {
                final agentAsync = ref.watch(agentDetailProvider(agentId));
                final agent = agentAsync.valueOrNull;
                if (agent == null) return const SizedBox.shrink();
                return GestureDetector(
                  onTap: onBack,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: AppColors.infoBackground,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              agent.fullName.isNotEmpty
                                  ? agent.fullName[0].toUpperCase()
                                  : '?',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.infoText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                agent.fullName,
                                style: AppTextStyles.labelMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Tap to view agent details',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: AppColors.textTertiary,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
