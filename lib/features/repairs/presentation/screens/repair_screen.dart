import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/standalone_mobile_screen_scaffold.dart';
import '../../../guide/core/constants/guide_keys.dart';
import '../../../guide/presentation/widgets/guide_contextual_hint_banner.dart';
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
  bool _repairHintEligible(RepairScreenState state) {
    return state != RepairScreenState.notAvailable &&
        state != RepairScreenState.noRepair;
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(preferredCurrencyProvider);
    final screenState = ref.watch(repairScreenStateProvider(widget.orderId));
    final forceQuoteSentScreen =
        ref.watch(repairQuoteAcceptSubmittingProvider(widget.orderId));
    final effectiveState = forceQuoteSentScreen
        ? RepairScreenState.quoteSent
        : screenState;
    final jobAsync = ref.watch(repairJobProvider(widget.orderId));
    final order = ref.watch(orderProvider(widget.orderId)).valueOrNull;
    final needsDutyClearance =
        (order?.stageNumber ?? 0) >= 8 && jobAsync.valueOrNull == null;
    final dutyAsync = needsDutyClearance
        ? ref.watch(dutyClearanceProvider(widget.orderId))
        : const AsyncValue.data(null);

    final isLoading =
        jobAsync.isLoading || (needsDutyClearance && dutyAsync.isLoading);
    final hasError =
        jobAsync.hasError || (needsDutyClearance && dutyAsync.hasError);

    final orderRef =
        ref.watch(orderProvider(widget.orderId)).valueOrNull?.orderRef ??
        widget.orderId;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_repairHintEligible(screenState))
          const GuideHint(guideKey: GuideKeys.stageRepair),
        Expanded(
          child: hasError
              ? RepairErrorCard(
                  onRetry: () {
                    ref.invalidate(repairJobProvider(widget.orderId));
                    if (needsDutyClearance) {
                      ref.invalidate(dutyClearanceProvider(widget.orderId));
                    }
                  },
                )
              : isLoading
              ? const RepairLoadingBody()
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: RepairBody(
                    key: ValueKey(effectiveState),
                    orderId: widget.orderId,
                    screenState: effectiveState,
                    job: jobAsync.valueOrNull,
                    dutyClearedAt: dutyAsync.valueOrNull?.clearedAt,
                    currency: currency,
                    onOpenChat: widget.onOpenChat,
                    onOpenDelivery: widget.onOpenDelivery,
                  ),
                ),
        ),
      ],
    );

    if (widget.embedInWebPanel) {
      return OrderDetailWebPanelChrome(
        title: 'Repairs',
        orderRef: orderRef,
        onBack: widget.onClosePanel ?? () {},
        child: body,
      );
    }

    return StandaloneMobileScreenScaffold(
      title: 'Repairs',
      onBack: () => context.pop(),
      actions: [standaloneOrderRefTrailing(orderRef)],
      titleStyle: AppTextStyles.titleMedium.copyWith(
        fontSize: 18,
        color: AppColors.foreground,
      ),
      body: body,
    );
  }
}
