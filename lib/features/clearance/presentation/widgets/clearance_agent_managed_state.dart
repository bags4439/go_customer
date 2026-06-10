import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/widgets/card_container.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../shipping/domain/entities/shipping.dart';
import '../../core/constants/clearance_constants.dart';
import '../../domain/entities/duty_clearance.dart';
import '../../../../shared/providers/preferred_currency_provider.dart';
import '../providers/clearance_providers.dart';
import 'clearance_always_one_animation.dart';
import 'clearance_arrival_bar.dart';
import 'clearance_details_card.dart';
import 'clearance_timeline_stage_row.dart';

class ClearanceAgentManagedState extends ConsumerStatefulWidget {
  const ClearanceAgentManagedState({
    super.key,
    required this.orderId,
    required this.shipping,
    required this.duty,
  });

  final String orderId;
  final Shipping shipping;
  final DutyClearance duty;

  @override
  ConsumerState<ClearanceAgentManagedState> createState() =>
      _ClearanceAgentManagedStateState();
}

class _ClearanceAgentManagedStateState
    extends ConsumerState<ClearanceAgentManagedState>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  final List<bool> _stageVisible = [false, false, false, false];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncAgentNotificationIfNeeded();
    });
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    for (var i = 0; i < 4; i++) {
      Future.delayed(Duration(milliseconds: i * 80), () {
        if (mounted) {
          setState(() => _stageVisible[i] = true);
        }
      });
    }
  }

  Future<void> _syncAgentNotificationIfNeeded() async {
    if (!widget.duty.isAgentHandled) return;
    if (ref.read(clearanceAgentNotifySyncedProvider(widget.orderId))) {
      return;
    }
    ref.read(clearanceAgentNotifySyncedProvider(widget.orderId).notifier).state =
        true;
    await ref.read(dutyClearanceRepositoryProvider).syncAgentClearanceNotification(
      orderId: widget.orderId,
      choice: 'agent',
    );
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
    final graStatus = widget.duty.graStatus;
    final preferredCurrency = ref.watch(preferredCurrencyProvider);
    final hasDetails =
        widget.duty.icumsRef != null ||
        widget.duty.clearingAgentName != null ||
        widget.duty.totalPayableUsd != null ||
        (widget.duty.notes != null && widget.duty.notes!.isNotEmpty);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                ClearanceArrivalBar(
                  animation: const ClearanceAlwaysOneAnimation(),
                  arrivalDate: widget.shipping.actualArrival,
                ),
                const SizedBox(height: 28),
             CardContainer(
                 paddingType: CardContainerPaddingType.xlarge,
                 child:  Column(
               children: [
                 ClearanceTimelineStageRow(
                   index: 0,
                   label: ClearanceConstants.stage2Arrived,
                   isDone: true,
                   isActive: false,
                   date: widget.shipping.actualArrival,
                   visible: _stageVisible[0],
                 ),
                 ClearanceTimelineStageRow(
                   index: 1,
                   label: ClearanceConstants.stage2Assessed,
                   isDone:
                   graStatus == 'assessed' ||
                       graStatus == 'paid' ||
                       graStatus == 'cleared',
                   isActive: graStatus == 'submitted',
                   date: widget.duty.assessedAt,
                   visible: _stageVisible[1],
                   pulseAnimation: _pulseController,
                 ),
                 ClearanceTimelineStageRow(
                   index: 2,
                   label: ClearanceConstants.stage2DutyPaid,
                   isDone: graStatus == 'paid' || graStatus == 'cleared',
                   isActive: graStatus == 'assessed',
                   date: widget.duty.paidAt,
                   visible: _stageVisible[2],
                   pulseAnimation: _pulseController,
                 ),
                 ClearanceTimelineStageRow(
                   index: 3,
                   label: ClearanceConstants.stage2Cleared,
                   isDone: graStatus == 'cleared',
                   isActive: graStatus == 'paid',
                   date: widget.duty.clearedAt,
                   visible: _stageVisible[3],
                   pulseAnimation: _pulseController,
                   isLast: true,
                 )
               ],
             )),
                if (hasDetails) ...[
                  const SizedBox(height: 24),
                  ClearanceDetailsCard(
                    duty: widget.duty,
                    preferredCurrency: preferredCurrency,
                  ),
                ],
                if (graStatus == 'assessed') ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.infoBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: AppColors.infoText,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            ClearanceConstants.state2AssessedNote,
                            style: AppTextStyles.cardLabel.copyWith(
                              color: AppColors.infoText,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(
            20,
            14,
            20,
            14 + MediaQuery.paddingOf(context).bottom,
          ),
          child: ElevatedButton(
            onPressed: () => context.go('/order/${widget.orderId}?tab=chat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(
              ClearanceConstants.askAgentButton(agentName),
              style: AppTextStyles.buttonLarge,
            ),
          ),
        ),
      ],
    );
  }
}
