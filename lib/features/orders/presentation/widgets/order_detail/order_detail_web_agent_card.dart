import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/features/orders/domain/entities/order_view.dart';
import 'package:go_customer/features/orders/presentation/providers/order_providers.dart';

class OrderDetailWebAgentCard extends ConsumerWidget {
  const OrderDetailWebAgentCard({
    super.key,
    required this.orderId,
    required this.order,
    this.showChatButton = true,
    this.expandedAvatar = false,
  });

  final String orderId;
  final OrderView? order;
  final bool showChatButton;
  final bool expandedAvatar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentId = order?.agentId;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderSolid, width: .5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('YOUR AGENT', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 12),
          if (agentId == null)
            Text(
              'Agent not yet assigned',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            )
          else
            OrderDetailWebAgentCardContent(
              agentId: agentId,
              orderId: orderId,
              showChatButton: showChatButton,
              expandedAvatar: expandedAvatar,
            ),
        ],
      ),
    );
  }
}

class OrderDetailWebAgentCardContent extends ConsumerWidget {
  const OrderDetailWebAgentCardContent({
    super.key,
    required this.agentId,
    required this.orderId,
    required this.showChatButton,
    required this.expandedAvatar,
  });

  final String agentId;
  final String orderId;
  final bool showChatButton;
  final bool expandedAvatar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentAsync = ref.watch(agentDetailProvider(agentId));

    return agentAsync.when(
      loading: () => const SizedBox(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.secondary,
            strokeWidth: 2,
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (agent) {
        if (agent == null) return const SizedBox.shrink();
        final avatarSize = expandedAvatar ? 56.0 : 44.0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.borderSolid,
                      width: 0.5,
                    ),
                  ),
                  child: ClipOval(
                    child: agent.photoUrl != null && agent.photoUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: agent.photoUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => OrderDetailWebAgentInitials(
                              name: agent.fullName,
                            ),
                            errorWidget: (_, __, ___) =>
                                OrderDetailWebAgentInitials(
                                  name: agent.fullName,
                                ),
                          )
                        : OrderDetailWebAgentInitials(name: agent.fullName),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agent.fullName,
                        style: AppTextStyles.labelLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${agent.rating.toStringAsFixed(1)} ★ · '
                        '${agent.totalOrdersCompleted} orders',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (agent.introMessage.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '"${agent.introMessage}"',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                    height: 1.45,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (showChatButton)
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: () => context.go('/order/$orderId?tab=chat'),
                        icon: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Chat',
                          style: AppTextStyles.buttonMedium.copyWith(
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (showChatButton && agent.phone != null)
                  const SizedBox(width: 8),
                if (agent.phone != null)
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final uri = Uri(scheme: 'tel', path: agent.phone);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                        icon: const Icon(
                          Icons.call_rounded,
                          size: 14,
                          color: AppColors.secondary,
                        ),
                        label: Text(
                          'Call',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.secondary,
                          side: const BorderSide(
                            color: AppColors.secondary,
                            width: 0.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class OrderDetailWebAgentInitials extends StatelessWidget {
  const OrderDetailWebAgentInitials({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.infoBackground,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: AppTextStyles.titleSmall.copyWith(
            fontSize: 16,
            color: AppColors.secondary,
          ),
        ),
      ),
    );
  }
}
