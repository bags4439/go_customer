import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../guide/core/constants/guide_keys.dart';
import '../../../guide/presentation/widgets/coach_mark_overlay.dart';
import '../../../guide/presentation/widgets/guide_faq_sheet.dart';
import '../../../guide/presentation/widgets/spotlight_painter.dart';
import '../../domain/entities/agent_detail_view.dart';
import '../../domain/entities/order_view.dart';
import 'agent_connection_agent_avatar.dart';
import 'agent_connection_labels.dart';
import 'agent_connection_next_step.dart';
import 'agent_connection_stat_card.dart';

class AgentConnectionAssignedView extends ConsumerStatefulWidget {
  const AgentConnectionAssignedView({
    super.key,
    required this.orderId,
    required this.order,
    required this.agent,
  });

  final String orderId;
  final OrderView order;
  final AgentDetailView agent;

  @override
  ConsumerState<AgentConnectionAssignedView> createState() =>
      _AgentConnectionAssignedViewState();
}

class _AgentConnectionAssignedViewState
    extends ConsumerState<AgentConnectionAssignedView>
    with CoachMarkMixin<AgentConnectionAssignedView> {
  final _agentCardKey = GlobalKey();

  @override
  String get coachMarkKey => GuideKeys.agentProfile;

  String get _firstName {
    final parts = widget.agent.fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'agent';
    return parts.first;
  }

  @override
  Widget build(BuildContext context) {
    final edge = ResponsiveLayout.contentPadding(context);
    final agent = widget.agent;
    final order = widget.order;

    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.fromLTRB(edge.left, 20, edge.right, 32),
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successMutedBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Agent assigned',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            KeyedSubtree(
              key: _agentCardKey,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border.all(color: AppColors.borderSolid, width: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AgentConnectionAgentAvatar(
                          agent: agent,
                          radius: 28,
                          heroTag: 'agent_avatar_${agent.agentId}_connection',
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                agent.fullName,
                                style: GoogleFonts.dmSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Import Agent',
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: AgentConnectionStatCard(
                            value: '${agent.successRate.toStringAsFixed(0)}%',
                            label: 'Success rate',
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AgentConnectionStatCard(
                            value: agent.rating.toStringAsFixed(1),
                            label: 'Rating',
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AgentConnectionStatCard(
                            value: '${agent.totalOrdersCompleted}',
                            label: 'Orders done',
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: const Border(
                          left: BorderSide(
                            color: AppColors.secondary,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '"${agent.introMessage}"',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textPrimary,
                              height: 1.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '— $_firstName',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border.all(color: AppColors.borderSolid, width: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What happens next',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  AgentConnectionNextStep(
                    number: 1,
                    text: AgentConnectionLabels.nextStep1Text(order),
                  ),
                  const AgentConnectionNextStep(
                    number: 2,
                    text:
                        'Your agent sends vehicle options '
                        'with full cost breakdowns in chat',
                  ),
                  const AgentConnectionNextStep(
                    number: 3,
                    text:
                        'No payment until your agent sends '
                        'a payment request',
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (order.purchaseOrigin != 'any') ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sourcing from: ${order.purchaseOriginLabel}',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  context.go('/order/${widget.orderId}?tab=chat');
                },
                style:
                    ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ).copyWith(
                      overlayColor: WidgetStateProperty.all(
                        Colors.white.withValues(alpha: 0.1),
                      ),
                      elevation: WidgetStateProperty.resolveWith(
                        (states) =>
                            states.contains(WidgetState.pressed) ? 0 : 2,
                      ),
                      shadowColor: WidgetStateProperty.all(
                        AppColors.secondary.withValues(alpha: 0.3),
                      ),
                    ),
                child: Text(
                  'Open chat with $_firstName →',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (showCoachMark)
          CoachMarkOverlay(
            guideKey: GuideKeys.agentProfile,
            targetKey: _agentCardKey,
            title: 'Meet your dedicated agent',
            body:
                'This is the agent handling everything '
                'for your import. They search, negotiate, '
                'ship, clear and deliver — you just '
                'approve and pay.',
            spotlightShape: SpotlightShape.roundedRect,
            onDismiss: hideCoachMark,
            onFaqTap: () {
              hideCoachMark();
              GuideFaqSheet.show(context);
            },
          ),
      ],
    );
  }
}
