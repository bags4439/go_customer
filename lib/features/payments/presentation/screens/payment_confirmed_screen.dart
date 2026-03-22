import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/payment.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../providers/payment_providers.dart';

class PaymentConfirmedScreen extends ConsumerWidget {
  final String orderId;
  final String requestId;
  final String paymentId;

  const PaymentConfirmedScreen({
    super.key,
    required this.orderId,
    required this.requestId,
    required this.paymentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentAsync = ref.watch(paymentStatusProvider(paymentId));
    final requestAsync = ref.watch(paymentRequestProvider(requestId));
    final agentAsync = ref.watch(
      agentForPaymentProvider(requestAsync.valueOrNull?.createdByAgentId ?? ''),
    );
    final orderAsync = ref.watch(orderProvider(orderId));
    final orderRef = orderAsync.valueOrNull?.orderRef ?? orderId;

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

        return Scaffold(
          backgroundColor: const Color(0xFF1C1C1E),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white, size: 64),
                        const SizedBox(height: 16),
                        const Text(
                          'Payment confirmed!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${CurrencyFormatter.formatGhs(payment.amountGhs)} received. $agentName has been notified.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ReceiptRow('Amount paid', CurrencyFormatter.formatGhs(payment.amountGhs)),
                        _ReceiptRow('Payment method', _methodLabel(payment.method)),
                        _ReceiptRow(
                          'Date & time',
                          payment.confirmedAt != null
                              ? DateFormat('d MMM yyyy, h:mm a').format(payment.confirmedAt!)
                              : '—',
                        ),
                        _ReceiptRow('Order', orderRef),
                        _ReceiptRow('For', typeLabel),
                        const SizedBox(height: 8),
                        Text(
                          'Transaction ref: ${payment.providerRef ?? '—'}',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (payment.type == AppConstants.paymentRequestTypeVehicleBalanceAndShipping &&
                      requestAsync.valueOrNull?.depositDeductedGhs != null) ...[
                    const SizedBox(height: 16),
                    _DepositNote(
                      depositDeductedGhs: requestAsync.valueOrNull!.depositDeductedGhs!,
                      totalVehicleCost: payment.amountGhs + requestAsync.valueOrNull!.depositDeductedGhs!,
                    ),
                  ],
                  if (payment.type == AppConstants.paymentRequestTypeRepairFee) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: const Border(left: BorderSide(color: AppColors.success, width: 4)),
                      ),
                      child: const Text(
                        'Repair payment confirmed. Your agent will coordinate delivery once work is complete.',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => context.go('/order/$orderId'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C2C2E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('View my order →'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => _downloadReceipt(ref, payment.id),
                    child: const Text('Download receipt', style: TextStyle(color: AppColors.secondary)),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'CONFIRMED',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Payment')),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  String _methodLabel(String method) {
    switch (method) {
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

  void _downloadReceipt(WidgetRef ref, String paymentId) {
    // TODO: Call Cloud Function generatePaymentReceipt(paymentId)
    // ref.read(cloudFunctionsProvider).call('generatePaymentReceipt', {'paymentId': paymentId});
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReceiptRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _DepositNote extends StatelessWidget {
  final double depositDeductedGhs;
  final double totalVehicleCost;

  const _DepositNote({
    required this.depositDeductedGhs,
    required this.totalVehicleCost,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: const Border(left: BorderSide(color: AppColors.success, width: 4)),
      ),
      child: Text(
        'Your deposit of ${CurrencyFormatter.formatGhs(depositDeductedGhs)} was deducted. Total vehicle cost: ${CurrencyFormatter.formatGhs(totalVehicleCost)} — fully paid.',
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}
