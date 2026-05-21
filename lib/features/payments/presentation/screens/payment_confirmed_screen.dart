import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/currency_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/providers/preferred_currency_provider.dart';
import '../../../orders/presentation/providers/order_detail_providers.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../../orders/presentation/widgets/order_detail/order_detail_web_panel_chrome.dart';
import '../../domain/entities/payment.dart';
import '../providers/payment_providers.dart';

class PaymentConfirmedScreen extends ConsumerStatefulWidget {
  final String orderId;
  final String requestId;
  final String paymentId;
  final bool embedInWebPanel;
  final VoidCallback? onClosePanel;

  const PaymentConfirmedScreen({
    super.key,
    required this.orderId,
    required this.requestId,
    required this.paymentId,
    this.embedInWebPanel = false,
    this.onClosePanel,
  });

  @override
  ConsumerState<PaymentConfirmedScreen> createState() =>
      _PaymentConfirmedScreenState();
}

class _PaymentConfirmedScreenState
    extends ConsumerState<PaymentConfirmedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.invalidate(buyerOrdersProvider);
      ref.invalidate(paymentRequestProvider(widget.requestId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final paymentAsync = ref.watch(paymentStatusProvider(widget.paymentId));
    final requestAsync = ref.watch(paymentRequestProvider(widget.requestId));
    final agentAsync = ref.watch(
      agentForPaymentProvider(requestAsync.valueOrNull?.createdByAgentId ?? ''),
    );
    final orderAsync = ref.watch(orderProvider(widget.orderId));
    final orderRef = orderAsync.valueOrNull?.orderRef ?? widget.orderId;

    return paymentAsync.when(
      data: (payment) {
        if (payment == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Payment')),
            body: const Center(child: Text('Payment not found')),
          );
        }
        final typeLabel = paymentRequestTypeLabel(payment.type);
        final agentName = agentAsync.valueOrNull?.fullName ?? 'Agent';
        final currency = ref.watch(preferredCurrencyProvider);

        final scroll = SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SuccessHero(
                    payment: payment,
                    agentName: agentName,
                    currency: currency,
                  ),
                  const SizedBox(height: 16),
                  _ReceiptCard(
                    payment: payment,
                    orderRef: orderRef,
                    typeLabel: typeLabel,
                    currency: currency,
                  ),
                  if (payment.type ==
                          AppConstants.paymentRequestTypeVehicleBalanceAndShipping &&
                      requestAsync.valueOrNull?.depositDeductedUsd != null) ...[
                    const SizedBox(height: 12),
                    _DepositNote(
                      depositDeductedUsd:
                          requestAsync.valueOrNull!.depositDeductedUsd!,
                      totalVehicleCost: payment.amountUsd +
                          requestAsync.valueOrNull!.depositDeductedUsd!,
                    ),
                  ],
                  if (payment.type ==
                      AppConstants.paymentRequestTypeRepairFee) ...[
                    const SizedBox(height: 12),
                    const _RepairNote(),
                  ],
                  const SizedBox(height: 16),
                  const _WhatHappensNext(),
                  const SizedBox(height: 24),
                  // Receipt note
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your receipt has been saved to your order '
                            'documents tab.',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (widget.embedInWebPanel) {
                          resetWebOrderPanelTask(ref);
                        } else {
                          context.go('/order/${widget.orderId}');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'View order →',
                        style: AppTextStyles.buttonLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        if (widget.embedInWebPanel) {
                          resetWebOrderPanelTask(ref);
                        }
                        context.go('/home');
                      },
                      child: Text(
                        'Back to home',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );

        if (widget.embedInWebPanel) {
          return OrderDetailWebPanelChrome(
            title: 'Payment confirmed',
            orderRef: orderRef,
            onBack: widget.onClosePanel ?? () => resetWebOrderPanelTask(ref),
            child: ColoredBox(
              color: const Color(0xFF0A1628),
              child: scroll,
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFF0A1628),
          body: SafeArea(child: scroll),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Payment')),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _DepositNote extends ConsumerWidget {
  final double depositDeductedUsd;
  final double totalVehicleCost;

  const _DepositNote({
    required this.depositDeductedUsd,
    required this.totalVehicleCost,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(preferredCurrencyProvider);
    final depositStr = CurrencyFormatter.format(
      depositDeductedUsd * currency.usdToRate,
      currency,
    );
    final totalStr = CurrencyFormatter.format(
      totalVehicleCost * currency.usdToRate,
      currency,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(color: AppColors.success, width: 4),
        ),
      ),
      child: Text(
        'Your deposit of $depositStr was deducted. Total vehicle cost: $totalStr — fully paid.',
        style: AppTextStyles.bodySmall.copyWith(
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

/// Green checkmark hero section.
class _SuccessHero extends StatelessWidget {
  const _SuccessHero({
    required this.payment,
    required this.agentName,
    required this.currency,
  });

  final Payment payment;
  final String agentName;
  final CurrencyModel currency;

  @override
  Widget build(BuildContext context) {
    final amountStr = CurrencyFormatter.format(
      payment.amountUsd * currency.usdToRate,
      currency,
    );

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1D9E75),
                Color(0xFF27C28D),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1D9E75).withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Payment confirmed!',
          style: AppTextStyles.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$amountStr received. $agentName has been notified.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

/// Dark glass receipt card.
class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({
    required this.payment,
    required this.orderRef,
    required this.typeLabel,
    required this.currency,
  });

  final Payment payment;
  final String orderRef;
  final String typeLabel;
  final CurrencyModel currency;

  @override
  Widget build(BuildContext context) {
    final amountStr = CurrencyFormatter.format(
      payment.amountUsd * currency.usdToRate,
      currency,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1D9E75).withValues(alpha: 0.15),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amount paid',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  amountStr,
                  style: AppTextStyles.amountMedium.copyWith(
                    color: const Color(0xFF27C28D),
                  ),
                ),
              ],
            ),
          ),
          _DarkReceiptRow(
            label: 'Payment method',
            value: _methodLabelStatic(payment.method),
          ),
          _DarkReceiptRow(
            label: 'Date & time',
            value: payment.confirmedAt != null
                ? DateFormat('d MMM yyyy, h:mm a').format(payment.confirmedAt!)
                : '—',
          ),
          _DarkReceiptRow(
            label: 'Order',
            value: orderRef,
          ),
          _DarkReceiptRow(
            label: 'For',
            value: typeLabel,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Text(
              'Ref: ${payment.providerRef ?? '—'}',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _methodLabelStatic(String method) {
    switch (method) {
      case 'paystack_checkout':
        return 'Paystack Checkout';
      case FirestoreEnumValues.paymentMethodMtnMomo:
        return 'MTN Mobile Money';
      case FirestoreEnumValues.paymentMethodVodafoneCash:
        return 'Vodafone Cash';
      case FirestoreEnumValues.paymentMethodAirteltigoMoney:
        return 'AirtelTigo Money';
      case FirestoreEnumValues.paymentMethodCard:
        return 'Debit/Credit card';
      case FirestoreEnumValues.paymentMethodBankTransfer:
        return 'Bank transfer';
      default:
        return method;
    }
  }
}

class _DarkReceiptRow extends StatelessWidget {
  const _DarkReceiptRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 0.5,
          color: Colors.white.withValues(alpha: 0.07),
          margin: const EdgeInsets.symmetric(horizontal: 16),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              Text(
                value,
                style: AppTextStyles.labelMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// What happens next section.
class _WhatHappensNext extends StatelessWidget {
  const _WhatHappensNext();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHAT HAPPENS NEXT',
            style: AppTextStyles.sectionLabel.copyWith(
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 12),
          const _NextStep(
            done: true,
            label:
                'Your agent has been notified of your payment',
          ),
          const SizedBox(height: 8),
          const _NextStep(
            done: false,
            label:
                'Your order will progress to the next stage',
          ),
        ],
      ),
    );
  }
}

class _NextStep extends StatelessWidget {
  const _NextStep({
    required this.done,
    required this.label,
  });

  final bool done;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: done
                ? const Color(0xFF1D9E75).withValues(alpha: 0.3)
                : Colors.transparent,
            border: done
                ? null
                : Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
            shape: BoxShape.circle,
          ),
          child: done
              ? const Icon(
                  Icons.check_rounded,
                  size: 12,
                  color: Color(0xFF1D9E75),
                )
              : Center(
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _RepairNote extends StatelessWidget {
  const _RepairNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(
            color: AppColors.success,
            width: 4,
          ),
        ),
      ),
      child: Text(
        'Repair payment confirmed. Your agent will coordinate delivery once work is complete.',
        style: AppTextStyles.bodySmall.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }
}
