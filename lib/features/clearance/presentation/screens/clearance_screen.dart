import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: AppColors.textPrimary,
          onPressed: () => context.pop(),
        ),
        title: Text('Clearance', style: AppTextStyles.appBarTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.borderSolid),
        ),
      ),
      body: body,
    );
  }
}
