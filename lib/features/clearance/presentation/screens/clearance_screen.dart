import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/standalone_mobile_screen_scaffold.dart';
import '../../../orders/presentation/widgets/order_detail/order_detail_web_panel_chrome.dart';
import '../../../shipping/presentation/providers/shipping_providers.dart';
import '../providers/clearance_providers.dart';
import '../widgets/clearance_body.dart';
import '../widgets/clearance_error_card.dart';
import '../widgets/clearance_loading_body.dart';

class ClearanceScreen extends ConsumerWidget {
  const ClearanceScreen({
    super.key,
    required this.orderId,
    this.embedInWebPanel = false,
    this.onClosePanel,
    this.onOpenChat,
  });

  final String orderId;
  final bool embedInWebPanel;
  final VoidCallback? onClosePanel;
  final VoidCallback? onOpenChat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenState = ref.watch(clearanceScreenStateProvider(orderId));
    final forceChoiceScreen =
        ref.watch(clearanceChoiceSubmittingProvider(orderId));
    final shippingAsync = ref.watch(shippingProvider(orderId));
    final dutyAsync = ref.watch(dutyClearanceProvider(orderId));

    final isLoading = shippingAsync.isLoading || dutyAsync.isLoading;
    final hasError = shippingAsync.hasError || dutyAsync.hasError;

    final body = hasError
        ? ClearanceErrorCard(
            onRetry: () {
              ref.invalidate(shippingProvider(orderId));
              ref.invalidate(dutyClearanceProvider(orderId));
            },
          )
        : isLoading
        ? const ClearanceLoadingBody()
        : ClearanceBody(
            orderId: orderId,
            screenState: screenState,
            shipping: shippingAsync.valueOrNull,
            duty: dutyAsync.valueOrNull,
            onOpenChat: onOpenChat,
            forceChoiceScreen: forceChoiceScreen,
          );

    if (embedInWebPanel) {
      return OrderDetailWebPanelChrome(
        title: 'Clearance',
        onBack: onClosePanel ?? () {},
        child: body,
      );
    }

    return StandaloneMobileScreenScaffold(
      title: 'Clearance',
      onBack: () => context.pop(),
      body: body,
    );
  }
}
