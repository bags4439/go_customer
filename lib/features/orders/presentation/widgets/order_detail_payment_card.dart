import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/providers/preferred_currency_provider.dart';
import '../../domain/entities/payment_request_view.dart';

String? formatOrderDetailDeadline(DateTime deadlineAt) {
  final now = DateTime.now();
  final diff = deadlineAt.difference(now);
  final days = diff.inDays;
  if (days <= 0) {
    return 'Pay today · avoid storage charges';
  }
  if (days == 1) {
    return 'Pay within 1 day · avoid storage charges';
  }
  return 'Pay within $days days · avoid storage charges';
}

/// Gradient payment CTA for order overview.
/// Displays amount in user's preferred currency
/// with USD equivalent secondary.
class OrderDetailPaymentCard extends ConsumerWidget {
  const OrderDetailPaymentCard({
    super.key,
    required this.payment,
    required this.typeLabel,
    required this.deadlineText,
    required this.onPayPressed,
  });

  final PaymentRequestView payment;
  final String typeLabel;
  final String? deadlineText;
  final VoidCallback onPayPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(preferredCurrencyProvider);
    final display = CurrencyFormatter.formatForDisplay(
      usdAmount: payment.amountUsd,
      preferredCurrency: currency,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.secondary, AppColors.infoText],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.30),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'PAYMENT REQUIRED',
                  style: AppTextStyles.badgeText.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            display.primary,
            style: AppTextStyles.amountLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          if (display.hasSecondary) ...[
            const SizedBox(height: 2),
            Text(
              display.secondary!,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.70),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            typeLabel,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          if (deadlineText != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.access_time_outlined,
                  size: 12,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    deadlineText!,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: onPayPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.background,
                foregroundColor: AppColors.secondary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Pay now →',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
