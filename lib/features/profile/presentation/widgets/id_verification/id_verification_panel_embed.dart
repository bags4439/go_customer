import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_customer/core/theme/app_colors.dart';

import '../../../../orders/presentation/providers/order_providers.dart';
import '../../../../orders/presentation/widgets/order_detail/order_detail_web_panel_chrome.dart';
import '../../providers/profile_providers.dart';
import 'id_verification_form.dart';

/// ID verification embedded in the order-detail web right panel.
class IdVerificationPanelEmbed extends ConsumerWidget {
  const IdVerificationPanelEmbed({
    super.key,
    required this.orderId,
    required this.onClose,
  });

  final String orderId;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderRef =
        ref.watch(orderProvider(orderId)).valueOrNull?.orderRef ?? orderId;
    final docLabel = ref.watch(currentUserProfileProvider).valueOrNull
            ?.idDocumentLabel ??
        'Identity document';

    return OrderDetailWebPanelChrome(
      title: docLabel,
      orderRef: orderRef,
      onBack: onClose,
      child: ColoredBox(
        color: AppColors.background,
        child: IdVerificationForm(
          showHeading: true,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          onSuccess: onClose,
        ),
      ),
    );
  }
}
