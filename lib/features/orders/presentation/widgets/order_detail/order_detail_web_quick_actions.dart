import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/core/utils/currency_formatter.dart';
import 'package:go_customer/shared/providers/preferred_currency_provider.dart';
import 'package:go_customer/features/orders/presentation/providers/order_providers.dart';

class OrderDetailWebQuickActionsCard extends ConsumerWidget {
  const OrderDetailWebQuickActionsCard({
    super.key,
    required this.orderId,
    required this.onPaymentTap,
  });

  final String orderId;

  /// [paymentRequestId] when a pending request exists.
  final void Function(String? paymentRequestId) onPaymentTap;

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
            onTap: () => onPaymentTap(payment.id),
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
