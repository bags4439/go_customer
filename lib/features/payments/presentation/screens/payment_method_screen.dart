import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/paystack_payment_service.dart';
import '../../domain/entities/payment_request.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/payment_providers.dart';

class PaymentMethodScreen extends ConsumerStatefulWidget {
  final String orderId;
  final String requestId;

  const PaymentMethodScreen({
    super.key,
    required this.orderId,
    required this.requestId,
  });

  @override
  ConsumerState<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends ConsumerState<PaymentMethodScreen> {
  static const String _momoPrefix = '+233';

  @override
  Widget build(BuildContext context) {
    final requestAsync = ref.watch(paymentRequestProvider(widget.requestId));
    final selectedMethod = ref.watch(selectedPaymentMethodProvider);
    final momoNumber = ref.watch(momoNumberProvider);

    return requestAsync.when(
      data: (request) {
        if (request == null || !request.isPending) {
          return Scaffold(
            appBar: AppBar(title: const Text('Checkout')),
            body: const Center(child: Text('Request not found or no longer pending')),
          );
        }
        final typeLabel = paymentRequestTypeLabel(request.type);
        final isMomo = selectedMethod == PaymentMethod.mtnMomo ||
            selectedMethod == PaymentMethod.vodafoneCash ||
            selectedMethod == PaymentMethod.airteltigoMoney;
        final processingFee = 0.0;
        final total = request.totalGhs + processingFee;
        final canProceed = !isMomo || _isValidMomo(momoNumber);

        return Scaffold(
          backgroundColor: const Color(0xFF1C1C1E),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            title: Text(
              '$typeLabel · ${CurrencyFormatter.formatGhs(request.totalGhs)}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Mobile Money',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 8),
                _MethodCard(
                  method: PaymentMethod.mtnMomo,
                  label: 'MTN Mobile Money',
                  subtitle: 'Instant',
                  isSelected: selectedMethod == PaymentMethod.mtnMomo,
                  onTap: () => ref.read(selectedPaymentMethodProvider.notifier).state = PaymentMethod.mtnMomo,
                ),
                const SizedBox(height: 8),
                _MethodCard(
                  method: PaymentMethod.vodafoneCash,
                  label: 'Vodafone Cash',
                  subtitle: 'Instant',
                  isSelected: selectedMethod == PaymentMethod.vodafoneCash,
                  onTap: () => ref.read(selectedPaymentMethodProvider.notifier).state = PaymentMethod.vodafoneCash,
                ),
                const SizedBox(height: 8),
                _MethodCard(
                  method: PaymentMethod.airteltigoMoney,
                  label: 'AirtelTigo Money',
                  subtitle: 'Instant',
                  isSelected: selectedMethod == PaymentMethod.airteltigoMoney,
                  onTap: () => ref.read(selectedPaymentMethodProvider.notifier).state = PaymentMethod.airteltigoMoney,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Other',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 8),
                _MethodCard(
                  method: PaymentMethod.card,
                  label: 'Debit/Credit card',
                  subtitle: 'Visa, Mastercard',
                  isSelected: selectedMethod == PaymentMethod.card,
                  onTap: () => ref.read(selectedPaymentMethodProvider.notifier).state = PaymentMethod.card,
                ),
                const SizedBox(height: 8),
                _MethodCard(
                  method: PaymentMethod.bankTransfer,
                  label: 'Bank transfer',
                  subtitle: '1-2 business days',
                  isSelected: selectedMethod == PaymentMethod.bankTransfer,
                  onTap: () => ref.read(selectedPaymentMethodProvider.notifier).state = PaymentMethod.bankTransfer,
                ),
                if (isMomo) ...[
                  const SizedBox(height: 24),
                  TextField(
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'MoMo number',
                      hintText: '$_momoPrefix XX XXX XXXX',
                      prefixText: '$_momoPrefix ',
                      prefixStyle: const TextStyle(color: Colors.white),
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
                    ),
                    onChanged: (v) => ref.read(momoNumberProvider.notifier).state = v.replaceAll(RegExp(r'\D'), ''),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You will receive a MoMo prompt to enter your PIN',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _SummaryRow('Amount', CurrencyFormatter.formatGhs(request.totalGhs)),
                      const SizedBox(height: 8),
                      _SummaryRow('Processing fee', CurrencyFormatter.formatGhs(processingFee)),
                      const Divider(color: Colors.white24),
                      _SummaryRow('Total', CurrencyFormatter.formatGhs(total), bold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: canProceed
                        ? () => _onConfirmAndPay(context, ref, request, total)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Confirm & pay ${CurrencyFormatter.formatGhs(total)} →'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  bool _isValidMomo(String digits) {
    if (digits.length != 9) return false;
    return RegExp(r'^[0-9]{9}$').hasMatch(digits);
  }

  Future<void> _onConfirmAndPay(BuildContext context, WidgetRef ref, PaymentRequest request, double totalGhs) async {
    final method = ref.read(selectedPaymentMethodProvider);
    if (method == null) return;
    final buyerId = ref.read(authStateProvider).value;
    if (buyerId == null) return;

    final providerRef = generatePaystackReference(widget.orderId, widget.requestId);
    final paymentOrFailure = await ref.read(paymentRepositoryProvider).createPayment(
          orderId: widget.orderId,
          buyerId: buyerId,
          paymentRequestId: widget.requestId,
          type: request.type,
          description: request.description,
          amountGhs: totalGhs,
          amountUsd: request.totalUsd,
          exchangeRate: request.exchangeRate,
          method: _methodToString(method),
          providerRef: providerRef,
        );

    paymentOrFailure.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (payment) async {
        ref.read(activePaymentProvider(widget.orderId).notifier).state = payment;
        ref.read(paymentTimeoutProvider.notifier).start(payment.id);

        final email = ref.read(currentUserProvider).value?.email ?? 'buyer@autoimport.gh';
        final launched = await initiatePaystackCharge(
          context: context,
          reference: providerRef,
          amountGhs: totalGhs,
          customerEmail: email,
        );

        if (context.mounted) {
          context.push(
            '/order/${widget.orderId}/payment-request/${widget.requestId}/processing?paymentId=${payment.id}',
          );
        }
      },
    );
  }

  String _methodToString(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.mtnMomo:
        return FirestoreEnumValues.paymentMethodMtnMomo;
      case PaymentMethod.vodafoneCash:
        return FirestoreEnumValues.paymentMethodVodafoneCash;
      case PaymentMethod.airteltigoMoney:
        return FirestoreEnumValues.paymentMethodAirteltigoMoney;
      case PaymentMethod.card:
        return FirestoreEnumValues.paymentMethodCard;
      case PaymentMethod.bankTransfer:
        return FirestoreEnumValues.paymentMethodBankTransfer;
    }
  }
}

class _MethodCard extends StatelessWidget {
  final PaymentMethod method;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodCard({
    required this.method,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.secondary : Colors.white24,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                method == PaymentMethod.card ? Icons.credit_card : Icons.phone_android,
                color: Colors.white70,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              if (isSelected) const Icon(Icons.check_circle, color: AppColors.secondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _SummaryRow(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
