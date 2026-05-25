import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../guide/core/constants/guide_keys.dart';
import '../../../guide/presentation/providers/guide_providers.dart';
import '../../../guide/presentation/widgets/coach_mark_overlay.dart';
import '../../../guide/presentation/widgets/guide_faq_sheet.dart';
import '../../../guide/presentation/widgets/guide_help_button.dart';
import '../../../guide/presentation/widgets/spotlight_painter.dart';
import '../../../clearance/presentation/providers/clearance_providers.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../../orders/presentation/widgets/order_detail/order_detail_web_panel_chrome.dart';
import '../../../../shared/providers/preferred_currency_provider.dart';
import '../providers/repair_providers.dart';
import '../widgets/repair_body.dart';
import '../widgets/repair_error_card.dart';
import '../widgets/repair_loading_body.dart';

class RepairScreen extends ConsumerStatefulWidget {
  const RepairScreen({
    super.key,
    required this.orderId,
    this.embedInWebPanel = false,
    this.onClosePanel,
    this.onOpenChat,
    this.onOpenDelivery,
  });

  final String orderId;
  final bool embedInWebPanel;
  final VoidCallback? onClosePanel;
  final VoidCallback? onOpenChat;
  final VoidCallback? onOpenDelivery;

  @override
  ConsumerState<RepairScreen> createState() => _RepairScreenState();
}

class _RepairScreenState extends ConsumerState<RepairScreen> {
  final GlobalKey _repairCoachKey = GlobalKey();
  bool _showRepairCoach = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowRepairCoach());
  }

  bool _repairCoachEligible(RepairScreenState state) {
    return state != RepairScreenState.notAvailable &&
        state != RepairScreenState.noRepair;
  }

  Future<void> _maybeShowRepairCoach() async {
    if (!mounted) return;
    final screenState = ref.read(repairScreenStateProvider(widget.orderId));
    if (!_repairCoachEligible(screenState)) return;
    final seen = await ref.read(
      hasSeenGuideProvider(GuideKeys.stageRepair).future,
    );
    if (!seen && mounted) {
      setState(() => _showRepairCoach = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(preferredCurrencyProvider);
    final screenState = ref.watch(repairScreenStateProvider(widget.orderId));
    final jobAsync = ref.watch(repairJobProvider(widget.orderId));
    final dutyAsync = ref.watch(dutyClearanceProvider(widget.orderId));

    final isLoading = jobAsync.isLoading || dutyAsync.isLoading;
    final hasError = jobAsync.hasError || dutyAsync.hasError;

    final orderRef =
        ref.watch(orderProvider(widget.orderId)).valueOrNull?.orderRef ??
        widget.orderId;

    final stackBody = Stack(
      fit: StackFit.expand,
      children: [
        KeyedSubtree(
          key: _repairCoachKey,
          child: hasError
              ? RepairErrorCard(
                  onRetry: () {
                    ref.invalidate(repairJobProvider(widget.orderId));
                    ref.invalidate(dutyClearanceProvider(widget.orderId));
                  },
                )
              : isLoading
              ? const RepairLoadingBody()
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: RepairBody(
                    key: ValueKey(screenState),
                    orderId: widget.orderId,
                    screenState: screenState,
                    job: jobAsync.valueOrNull,
                    dutyClearedAt: dutyAsync.valueOrNull?.clearedAt,
                    currency: currency,
                    onOpenChat: widget.onOpenChat,
                    onOpenDelivery: widget.onOpenDelivery,
                  ),
                ),
        ),
        if (_showRepairCoach && _repairCoachEligible(screenState))
          CoachMarkOverlay(
            guideKey: GuideKeys.stageRepair,
            targetKey: _repairCoachKey,
            title: 'Review your repair quote',
            body:
                'Your agent sent a repair quote. '
                'Check the details carefully — '
                'no work begins until you approve it.',
            spotlightShape: SpotlightShape.roundedRect,
            onDismiss: () => setState(() => _showRepairCoach = false),
            onFaqTap: () {
              setState(() => _showRepairCoach = false);
              GuideFaqSheet.show(context);
            },
          ),
      ],
    );

    if (widget.embedInWebPanel) {
      return OrderDetailWebPanelChrome(
        title: 'Repairs',
        orderRef: orderRef,
        onBack: widget.onClosePanel ?? () {},
        child: stackBody,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
          style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
        ),
        title: Text(
          'Repairs',
          style: AppTextStyles.titleMedium.copyWith(
            fontSize: 18,
            color: AppColors.primary,
          ),
        ),
        actions: [
          GuideHelpButton(
            onShowGuide: () => setState(() => _showRepairCoach = true),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                orderRef,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        ],
      ),
      body: stackBody,
    );
  }
}
