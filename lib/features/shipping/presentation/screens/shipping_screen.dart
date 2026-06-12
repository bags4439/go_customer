import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/standalone_mobile_screen_scaffold.dart';
import '../../data/models/shipping_model.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../../orders/presentation/providers/order_timeline_providers.dart';
import '../../../orders/presentation/widgets/order_detail/order_detail_web_panel_chrome.dart';
import '../providers/shipping_providers.dart';
import '../widgets/shipping_arrived_state.dart';
import '../widgets/shipping_booked_state.dart';
import '../widgets/shipping_error_state.dart';
import '../widgets/shipping_in_transit_state.dart';
import '../widgets/shipping_loading_state.dart';
import '../widgets/shipping_not_arranged.dart';
import '../widgets/shipping_released_state.dart';

class ShippingScreen extends ConsumerWidget {
  const ShippingScreen({
    super.key,
    required this.orderId,
    this.embedInWebPanel = false,
    this.onClosePanel,
  });

  final String orderId;
  final bool embedInWebPanel;
  final VoidCallback? onClosePanel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shippingAsync = ref.watch(orderShippingProvider(orderId));
    final orderAsync = ref.watch(orderProvider(orderId));
    final orderRef = orderAsync.valueOrNull?.orderRef ?? orderId;

    final body = shippingAsync.when(
      data: (shipping) {
        if (shipping == null) {
          return ShippingNotArranged(orderId: orderId);
        }
        final state = ref.watch(shippingScreenStateProvider(orderId));
        final entity = shipping.toEntity();
        return switch (state) {
          ShippingScreenState.notArranged =>
            ShippingNotArranged(orderId: orderId),
          ShippingScreenState.booked =>
            ShippingBookedState(orderId: orderId, shipping: entity),
          ShippingScreenState.inTransit =>
            ShippingInTransitState(orderId: orderId, shipping: entity),
          ShippingScreenState.arrived =>
            ShippingArrivedState(orderId: orderId, shipping: entity),
          ShippingScreenState.released =>
            ShippingReleasedState(orderId: orderId, shipping: entity),
        };
      },
      loading: () => const ShippingLoadingState(),
      error: (e, _) => ShippingErrorState(message: e.toString()),
    );

    if (embedInWebPanel) {
      return OrderDetailWebPanelChrome(
        title: 'Shipping tracker',
        orderRef: orderRef,
        onBack: onClosePanel ?? () {},
        child: body,
      );
    }

    return StandaloneMobileScreenScaffold(
      title: 'Shipping tracker',
      onBack: () => context.pop(),
      actions: [standaloneOrderRefTrailing(orderRef)],
      body: body,
    );
  }
}
