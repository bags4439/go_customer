import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/card_container.dart';
import '../../../core/constants/order_edit_constants.dart';
import '../../providers/order_providers.dart';
import '../order_detail/order_detail_web_agent_card.dart';

/// Call, WhatsApp, and in-app message actions before the buyer cancels.
class CancelAgentContactSection extends ConsumerWidget {
  const CancelAgentContactSection({
    super.key,
    required this.orderId,
    required this.agentId,
    required this.agentName,
  });

  final String orderId;
  final String agentId;
  final String agentName;

  static String _sanitiseWhatsAppNumber(String phone) {
    return phone.replaceAll(RegExp(r'\D'), '');
  }

  Future<void> _launchExternal(BuildContext context, Uri uri) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        _showLaunchError(context);
      }
    } catch (_) {
      if (context.mounted) _showLaunchError(context);
    }
  }

  void _showLaunchError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          OrderEditConstants.contactLaunchError,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentAsync = ref.watch(agentDetailProvider(agentId));

    return agentAsync.when(
      loading: () => const _ContactShimmer(),
      error: (_, __) => const SizedBox.shrink(),
      data: (agent) {
        if (agent == null) return const SizedBox.shrink();
        return _ContactCard(
          orderId: orderId,
          agent: agent,
          agentName: agentName,
          onCall: agent.phone != null && agent.phone!.trim().isNotEmpty
              ? () => _launchExternal(
                  context,
                  Uri(scheme: 'tel', path: agent.phone!.trim()),
                )
              : null,
          onWhatsApp: () {
            final wa = agent.whatsappNumberForContact;
            if (wa == null) return;
            final digits = _sanitiseWhatsAppNumber(wa);
            if (digits.isEmpty) return;
            _launchExternal(context, Uri.parse('https://wa.me/$digits'));
          },
          onMessage: () => context.go('/order/$orderId?tab=chat'),
          hasWhatsApp: agent.whatsappNumberForContact != null &&
              _sanitiseWhatsAppNumber(agent.whatsappNumberForContact!).isNotEmpty,
        );
      },
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.orderId,
    required this.agent,
    required this.agentName,
    required this.onCall,
    required this.onWhatsApp,
    required this.onMessage,
    required this.hasWhatsApp,
  });

  final String orderId;
  final AgentDetailView agent;
  final String agentName;
  final VoidCallback? onCall;
  final VoidCallback onWhatsApp;
  final VoidCallback onMessage;
  final bool hasWhatsApp;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      paddingType: CardContainerPaddingType.large,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            OrderEditConstants.contactAgentHeading,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            OrderEditConstants.contactAgentSubtitle
                .replaceAll('[agentFirstName]', agentName),
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _AgentAvatar(agent: agent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agent.fullName,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${agent.rating.toStringAsFixed(1)} ★ · '
                      '${agent.totalOrdersCompleted} orders',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ContactActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: OrderEditConstants.messageAgentButton,
                  isPrimary: true,
                  onTap: onMessage,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ContactActionButton(
                  icon: Icons.call_rounded,
                  label: OrderEditConstants.callAgentButton,
                  onTap: onCall,
                  enabled: onCall != null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ContactActionButton(
                  icon: Icons.chat_rounded,
                  label: OrderEditConstants.whatsappAgentButton,
                  accentColor: const Color(0xFF25D366),
                  onTap: hasWhatsApp ? onWhatsApp : null,
                  enabled: hasWhatsApp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AgentAvatar extends StatelessWidget {
  const _AgentAvatar({required this.agent});

  final AgentDetailView agent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderSolid, width: 0.5),
      ),
      child: ClipOval(
        child: agent.photoUrl != null && agent.photoUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: agent.photoUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    OrderDetailWebAgentInitials(name: agent.fullName),
                errorWidget: (_, __, ___) =>
                    OrderDetailWebAgentInitials(name: agent.fullName),
              )
            : OrderDetailWebAgentInitials(name: agent.fullName),
      ),
    );
  }
}

class _ContactActionButton extends StatelessWidget {
  const _ContactActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
    this.enabled = true,
    this.accentColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isPrimary;
  final bool enabled;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final canTap = enabled && onTap != null;
    final color = accentColor ?? AppColors.secondary;

    if (isPrimary) {
      return SizedBox(
        height: 52,
        child: FilledButton(
          onPressed: canTap ? onTap : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.secondary,
            disabledBackgroundColor: AppColors.borderSolid,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: canTap ? onTap : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: canTap ? color : AppColors.textTertiary,
          side: BorderSide(
            color: canTap ? AppColors.borderSolid : AppColors.borderSolid,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: canTap ? color : AppColors.textTertiary),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: canTap ? AppColors.textPrimary : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactShimmer extends StatelessWidget {
  const _ContactShimmer();

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      paddingType: CardContainerPaddingType.large,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Shown when no agent is assigned yet on the cancel screen.
class CancelAgentPendingNote extends StatelessWidget {
  const CancelAgentPendingNote({super.key});

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      paddingType: CardContainerPaddingType.large,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.hourglass_empty_rounded,
            size: 18,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              OrderEditConstants.agentNotAssignedContactNote,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
