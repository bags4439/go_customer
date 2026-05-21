import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:go_customer/features/orders/presentation/providers/order_providers.dart';
import 'order_detail_agent_photo_viewer.dart';
import 'order_detail_ui.dart';

/// Mobile app bar title when the Chat tab is active.
class OrderDetailAgentAppBarTitle extends ConsumerWidget {
  const OrderDetailAgentAppBarTitle({super.key, required this.orderId});

  final String orderId;

  Future<void> _launchCall(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderProvider(orderId));
    final agentId = orderAsync.valueOrNull?.agentId;

    if (agentId == null) {
      return const SizedBox.shrink();
    }

    final agentAsync = ref.watch(agentDetailProvider(agentId));

    return agentAsync.when(
      data: (agent) {
        if (agent == null) {
          return const SizedBox.shrink();
        }
        return Row(
          children: [
            GestureDetector(
              onTap: (agent.photoUrl != null && agent.photoUrl!.isNotEmpty)
                  ? () => Navigator.of(context).push(
                      PageRouteBuilder<void>(
                        opaque: false,
                        barrierColor: Colors.black87,
                        transitionDuration: const Duration(milliseconds: 250),
                        pageBuilder: (_, __, ___) =>
                            OrderDetailAgentPhotoViewer(
                              photoUrl: agent.photoUrl!,
                              agentName: agent.fullName,
                            ),
                      ),
                    )
                  : null,
              child: Hero(
                tag: 'agent_photo_${agent.photoUrl ?? ''}',
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: OrderDetailUi.border, width: 0.5),
                  ),
                  child: ClipOval(
                    child: agent.photoUrl != null && agent.photoUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: agent.photoUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _avatarPlaceholder(),
                            errorWidget: (_, __, ___) => _avatarPlaceholder(),
                          )
                        : _avatarInitial(agent.fullName),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    agent.fullName,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: OrderDetailUi.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${agent.totalOrdersCompleted} orders · '
                    '${agent.rating.toStringAsFixed(1)} ★',
                    style: AppTextStyles.caption.copyWith(
                      color: OrderDetailUi.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (agent.phone != null && agent.phone!.isNotEmpty)
              GestureDetector(
                onTap: () => _launchCall(agent.phone),
                child: Container(
                  width: 34,
                  height: 34,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    color: OrderDetailUi.infoBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.call_rounded,
                    size: 17,
                    color: OrderDetailUi.primary,
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: OrderDetailUi.shimmer,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 120,
            height: 13,
            decoration: BoxDecoration(
              color: OrderDetailUi.shimmer,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _avatarPlaceholder() {
    return const ColoredBox(
      color: OrderDetailUi.infoBg,
      child: Icon(Icons.person_outline, size: 18, color: OrderDetailUi.primary),
    );
  }

  Widget _avatarInitial(String name) {
    return ColoredBox(
      color: OrderDetailUi.infoBg,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: AppTextStyles.labelLarge.copyWith(
            color: OrderDetailUi.primary,
          ),
        ),
      ),
    );
  }
}
