import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/currency_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../orders/presentation/widgets/order_detail/order_detail_web_navigation.dart';
import '../../../payments/data/models/payment_request_model.dart';

/// Lightweight link to a pending repair payment — reuses the standard
/// payment request flow (same as order timeline / overview).
class RepairPaymentPromptCard extends ConsumerWidget {
  const RepairPaymentPromptCard({
    super.key,
    required this.orderId,
    required this.payment,
    required this.currency,
    required this.buttonLabel,
  });

  final String orderId;
  final PaymentRequestModel payment;
  final CurrencyModel currency;
  final String buttonLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final display = CurrencyFormatter.formatForDisplay(
      usdAmount: payment.amountUsd,
      preferredCurrency: currency,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.infoBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            payment.type.label,
            style: AppTextStyles.sectionLabel.copyWith(
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
              fontSize: 11,
              color: AppColors.infoText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            display.primary,
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.secondary,
            ),
          ),
          if (display.hasSecondary) ...[
            const SizedBox(height: 2),
            Text(
              display.secondary!,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: () => OrderDetailWebNavigation.openPaymentRequest(
                context,
                ref,
                orderId: orderId,
                requestId: payment.id,
              ),
              child: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}
