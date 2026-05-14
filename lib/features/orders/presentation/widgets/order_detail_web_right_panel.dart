part of 'package:go_customer/features/orders/presentation/screens/order_detail_screen.dart';

/// Right contextual panel (flex 1 — equal width as left).
class _WebRightPanel extends ConsumerWidget {
  const _WebRightPanel({
    required this.orderId,
    required this.order,
    required this.currentTab,
  });

  final String orderId;
  final OrderView? order;
  final int currentTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedStep = ref.watch(webSelectedStepProvider);

    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(horizontal: 34),
      child: SingleChildScrollView(
        child: currentTab == 0
            ? _buildOverviewRight(context, ref, selectedStep)
            : currentTab == 1
            ? _buildChatRight()
            : _buildDocumentsRight(context),
      ),
    );
  }

  Widget _buildOverviewRight(
    BuildContext context,
    WidgetRef ref,
    String? selectedStep,
  ) {
    if (selectedStep != null) {
      return _WebStepDetail(
        orderId: orderId,
        order: order,
        stageKey: selectedStep,
        onBack: () => ref.read(webSelectedStepProvider.notifier).state = null,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 16),
        CardContainer(
          child: _WebAgentCard(
            orderId: orderId,
            order: order,
            showChatButton: true,
          ),
        ),
        SizedBox(height: 16),
        CardContainer(child: _WebOrderSummaryCard(order: order)),
        _WebQuickActionsCard(
          orderId: orderId,
          onPaymentTap: () =>
              ref.read(webSelectedStepProvider.notifier).state = 'deposit_paid',
        ),
      ],
    );
  }

  Widget _buildChatRight() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 16),
        CardContainer(
          child: _WebAgentCard(
            orderId: orderId,
            order: order,
            showChatButton: false,
            expandedAvatar: true,
          ),
        ),
        SizedBox(height: 16),
        CardContainer(child: _WebOrderContextCard(order: order)),
      ],
    );
  }

  Widget _buildDocumentsRight(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 16),
        CardContainer(child: _WebDocProgressCard(orderId: orderId)),
        SizedBox(height: 16),
        CardContainer(
          child: _WebAgentCard(
            orderId: orderId,
            order: order,
            showChatButton: true,
          ),
        ),
        SizedBox(height: 16),
        CardContainer(child: _WebDocHelpCard(orderId: orderId)),
      ],
    );
  }
}

class _WebQuickActionsCard extends ConsumerWidget {
  const _WebQuickActionsCard({
    required this.orderId,
    required this.onPaymentTap,
  });

  final String orderId;
  final VoidCallback onPaymentTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentAsync = ref.watch(activePaymentRequestProvider(orderId));
    final payment = paymentAsync.valueOrNull;

    if (payment == null) {
      return const SizedBox.shrink();
    }

    final currency = ref.watch(preferredCurrencyProvider);
    final display = CurrencyFormatter.formatForDisplay(
      usdAmount: payment.amountUsd,
      preferredCurrency: currency,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('QUICK ACTIONS', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onPaymentTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.amberBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.credit_card_rounded,
                      size: 16,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment due — ${display.primary}',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.amberText,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Tap to review & pay',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: AppColors.warning,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WebAgentCard extends ConsumerWidget {
  const _WebAgentCard({
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
            _WebAgentCardContent(
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

class _WebAgentCardContent extends ConsumerWidget {
  const _WebAgentCardContent({
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
                            placeholder: (_, __) =>
                                _AgentInitials(name: agent.fullName),
                            errorWidget: (_, __, ___) =>
                                _AgentInitials(name: agent.fullName),
                          )
                        : _AgentInitials(name: agent.fullName),
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

class _AgentInitials extends StatelessWidget {
  const _AgentInitials({required this.name});

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

class _WebOrderSummaryCard extends StatelessWidget {
  const _WebOrderSummaryCard({required this.order});

  final OrderView? order;

  static String? _yearPreferenceLabel(OrderView o) {
    if (o.yearMin != null && o.yearMax != null) {
      if (o.isSingleYear || o.yearMin == o.yearMax) {
        return '${o.yearMin}';
      }
      return '${o.yearMin}–${o.yearMax}';
    }
    if (o.yearMin != null) return '${o.yearMin}';
    if (o.yearMax != null) return '${o.yearMax}';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (order == null) return const SizedBox.shrink();
    final carName = '${order!.make ?? ''} ${order!.model ?? ''}'.trim();
    final yearLabel = _yearPreferenceLabel(order!);

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
          Text('ORDER SUMMARY', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 10),
          _RightPanelRow(
            label: 'Vehicle',
            value: carName.isNotEmpty ? carName : '—',
          ),
          _RightPanelRow(
            label: 'Source',
            value: orderDetailOriginLabel(order!.purchaseOrigin),
          ),
          _RightPanelRow(
            label: 'Stage',
            value: '${order!.stageNumber} of 9',
            valueBadge: true,
          ),
          if (yearLabel != null)
            _RightPanelRow(label: 'Year', value: yearLabel),
        ],
      ),
    );
  }
}

class _RightPanelRow extends StatelessWidget {
  const _RightPanelRow({
    required this.label,
    required this.value,
    this.valueBadge = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool valueBadge;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final Widget valueWidget;
    if (valueBadge) {
      valueWidget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.infoBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          value,
          style: AppTextStyles.cardValue.copyWith(color: AppColors.infoText),
        ),
      );
    } else {
      valueWidget = Text(
        value,
        style: valueColor != null
            ? AppTextStyles.cardValue.copyWith(color: valueColor)
            : AppTextStyles.cardValue,
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.cardLabel),
          valueWidget,
        ],
      ),
    );
  }
}

class _WebOrderContextCard extends StatelessWidget {
  const _WebOrderContextCard({required this.order});

  final OrderView? order;

  @override
  Widget build(BuildContext context) {
    if (order == null) return const SizedBox.shrink();
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
          Text('ORDER CONTEXT', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 10),
          _RightPanelRow(
            label: 'Stage',
            value: '${order!.stageNumber} of 9',
            valueBadge: true,
          ),
          _RightPanelRow(
            label: 'Payment',
            value: order!.needsPayment ? 'Due' : 'Up to date',
            valueColor: order!.needsPayment
                ? AppColors.danger
                : AppColors.successMutedForeground,
          ),
          _RightPanelRow(
            label: 'Vehicle',
            value: '${order!.make ?? ''} ${order!.model ?? ''}'.trim(),
          ),
        ],
      ),
    );
  }
}

/// Right panel step detail (web overview).
class _WebStepDetail extends ConsumerWidget {
  const _WebStepDetail({
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
