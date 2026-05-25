import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/currency_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../core/constants/repair_constants.dart';
import '../../domain/entities/repair_job.dart';
import '../../../clearance/presentation/providers/clearance_providers.dart';
import '../providers/repair_providers.dart';
import 'repair_formatters.dart';
import 'repair_garage_info_row.dart';
import 'repair_navigation.dart';
import 'repair_timeline_stage.dart';

class RepairInProgressState extends ConsumerStatefulWidget {
  const RepairInProgressState({
    super.key,
    required this.orderId,
    required this.job,
    required this.currency,
    this.onOpenChat,
  });

  final String orderId;
  final RepairJob job;
  final CurrencyModel currency;
  final VoidCallback? onOpenChat;

  @override
  ConsumerState<RepairInProgressState> createState() =>
      _RepairInProgressStateState();
}

class _RepairInProgressStateState extends ConsumerState<RepairInProgressState>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  final List<bool> _stageVisible = [false, false, false, false, false];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    for (var i = 0; i < 5; i++) {
      Future.delayed(Duration(milliseconds: i * 80), () {
        if (mounted) setState(() => _stageVisible[i] = true);
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final agentName =
        ref.watch(agentFirstNameProvider(widget.orderId)).valueOrNull ??
        'Your agent';
    final garageAsync = ref.watch(garageDetailsProvider(widget.job.garageId));
    final garage = garageAsync.valueOrNull;
    final garageName = widget.job.garageNameCustom ?? garage?.name ?? '—';
    const activeColor = Color(0xFF185FA5);
    final estCompletion = widget.job.estimatedCompletion;
    final now = DateTime.now();
    final daysLeft = estCompletion != null && estCompletion.isAfter(now)
        ? estCompletion.difference(now).inDays
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F1FB),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: Row(
              children: [
                const Text('🔧', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        RepairConstants.state3HeroTitle,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: activeColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        estCompletion != null
                            ? (daysLeft != null && daysLeft >= 0
                                  ? '${RepairConstants.state3EstCompletionPrefix} ${repairDisplayDateFormat.format(estCompletion)} · $daysLeft ${RepairConstants.state3DaysLeft}'
                                  : RepairConstants.state3FinishingUp)
                            : '—',
                        style: AppTextStyles.cardLabel.copyWith(
                          color: activeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  RepairConstants.garageDetailsLabel,
                  style: AppTextStyles.sectionLabel.copyWith(
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                    fontSize: 10,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 12),
                RepairGarageInfoRow(
                  label: RepairConstants.garageLabel,
                  value: garageName,
                ),
                RepairGarageInfoRow(
                  label: RepairConstants.locationLabel,
                  value: widget.job.garageLocation ?? '—',
                ),
                RepairGarageInfoRow(
                  label: RepairConstants.startedLabel,
                  value: widget.job.startDate != null
                      ? repairDisplayDateFormat.format(widget.job.startDate!)
                      : '—',
                ),
                RepairGarageInfoRow(
                  label: RepairConstants.estCompletionShortLabel,
                  value: estCompletion != null
                      ? repairDisplayDateFormat.format(estCompletion)
                      : '—',
                ),
                RepairGarageInfoRow(
                  label: RepairConstants.approvedQuoteLabel,
                  value: widget.job.totalQuotedGhs != null
                      ? CurrencyFormatter.format(
                          widget.job.totalQuotedGhs! *
                              widget.currency.usdToRate,
                          widget.currency,
                        )
                      : '—',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          RepairTimelineStage(
            index: 0,
            label: RepairConstants.stageQuoteApproved,
            isDone: true,
            isActive: false,
            date: widget.job.quoteApprovedAt,
            visible: _stageVisible[0],
          ),
          RepairTimelineStage(
            index: 1,
            label: RepairConstants.stageCarDropped,
            isDone: widget.job.startDate != null,
            isActive: false,
            date: widget.job.startDate,
            visible: _stageVisible[1],
          ),
          RepairTimelineStage(
            index: 2,
            label: RepairConstants.stageWorkInProgress,
            isDone: widget.job.isCompleted,
            isActive: widget.job.isInProgress,
            date: null,
            visible: _stageVisible[2],
            pulseAnimation: _pulseController,
          ),
          RepairTimelineStage(
            index: 3,
            label: RepairConstants.stageQualityCheck,
            isDone: false,
            isActive: false,
            date: null,
            visible: _stageVisible[3],
          ),
          RepairTimelineStage(
            index: 4,
            label: RepairConstants.stageReadyForDelivery,
            isDone: false,
            isActive: false,
            date: null,
            visible: _stageVisible[4],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Text(
              RepairConstants.state3PhotoNote,
              style: AppTextStyles.cardLabel.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.75),
              ),
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
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
