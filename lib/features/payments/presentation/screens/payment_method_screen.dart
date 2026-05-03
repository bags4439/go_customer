import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/providers/preferred_currency_provider.dart';
import '../../data/services/paystack_payment_service.dart';
import '../../domain/entities/payment_request.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
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
    final currency = ref.watch(preferredCurrencyProvider);
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
        final totalUsd = request.amountUsd + processingFee;
        final canProceed = !isMomo || _isValidMomo(momoNumber);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
              onPressed: () => context.pop(),
            ),
            title: Text(
              '$typeLabel · ${CurrencyFormatter.formatForDisplay(
                usdAmount: request.amountUsd,
                preferredCurrency: currency,
              ).primary}',
              style: const TextStyle(color: Colors.black87, fontSize: 16),
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
                  style: TextStyle(color: Colors.black54, fontSize: 12),
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
                  style: TextStyle(color: Colors.black54, fontSize: 12),
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
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'MoMo number',
                      hintText: '$_momoPrefix XX XXX XXXX',
                      prefixText: '$_momoPrefix ',
                      prefixStyle: const TextStyle(color: Colors.black87),
                      border: const OutlineInputBorder(),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFE0DFD8)),
                      ),
                    ),
                    onChanged: (v) => ref.read(momoNumberProvider.notifier).state = v.replaceAll(RegExp(r'\D'), ''),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You will receive a MoMo prompt to enter your PIN',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F4F0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0DFD8), width: 0.5),
                  ),
                  child: Column(
                    children: [
                      _SummaryRow(
                        'Amount',
                        CurrencyFormatter.format(
                          request.amountUsd * currency.usdToRate,
                          currency,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const _SummaryRow('Processing fee', 'Free'),
                      const Divider(color: Color(0xFFE0DFD8)),
                      _SummaryRow(
                        'Total',
                        CurrencyFormatter.format(
                          totalUsd * currency.usdToRate,
                          currency,
                        ),
                        bold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: canProceed
                        ? () => _onConfirmAndPay(ref, request, totalUsd)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child: Text(
                      'Confirm & pay ${CurrencyFormatter.format(
                        totalUsd * currency.usdToRate,
                        currency,
                      )} →',
                    ),
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

  Future<String?> _ensureEmail(
    BuildContext context,
    WidgetRef ref,
    AppUser user,
  ) async {
    if (user.email != null && user.email!.trim().isNotEmpty) {
      return user.email!.trim();
    }

    final email = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (ctx) => _EmailGateSheet(
        userId: user.id,
        ref: ref,
      ),
    );
    return email;
  }

  Future<void> _onConfirmAndPay(WidgetRef ref, PaymentRequest request, double totalUsd) async {
    final method = ref.read(selectedPaymentMethodProvider);
    if (method == null) return;
    final buyerId = ref.read(authStateProvider).value;
    if (buyerId == null) return;

    if (!mounted) return;
    final user = await ref.read(currentUserProvider.future);
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load your profile. Try again.')),
        );
      }
      return;
    }
    if (!mounted) return;
    final email = await _ensureEmail(context, ref, user);
    if (email == null || email.trim().isEmpty) {
      return;
    }

    final paymentRepo = ref.read(paymentRepositoryProvider);

    final providerRef = generatePaystackReference(widget.orderId, widget.requestId);
    final paymentOrFailure = await paymentRepo.upsertPendingPayment(
      orderId: widget.orderId,
      buyerId: buyerId,
      paymentRequestId: widget.requestId,
      type: request.type,
      description: request.description,
      amountUsd: totalUsd,
      exchangeRateAtPayment: request.exchangeRateAtRequest,
      paidCurrency: 'GHS',
      paidAmount: 0,
      method: _methodToString(method),
      providerRef: providerRef,
    );

    final payment = paymentOrFailure.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(failure.message)));
        }
        return null;
      },
      (p) => p,
    );

    if (payment == null) return;

    ref.read(activePaymentProvider(widget.orderId).notifier).state = payment;
    ref.read(paymentTimeoutProvider.notifier).start(payment.id);

    if (!mounted) return;
    final chargeGhs = totalUsd * request.exchangeRateAtRequest;
    final launched = await initiatePaystackCharge(
      context: context,
      reference: payment.providerRef ?? generatePaystackReference(widget.orderId, widget.requestId),
      chargeAmountGhs: chargeGhs,
      customerEmail: email.trim(),
    );

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Paystack checkout.')),
      );
      return;
    }

    if (mounted) {
      context.push(
        '/order/${widget.orderId}/payment-request/${widget.requestId}/processing?paymentId=${payment.id}',
      );
    }
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
              color: isSelected ? AppColors.secondary : const Color(0xFFE0DFD8),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                method == PaymentMethod.card ? Icons.credit_card : Icons.phone_android,
                color: Colors.black54,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                    Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 12)),
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
            color: Colors.black54,
            fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _EmailGateSheet extends StatefulWidget {
  const _EmailGateSheet({
    required this.userId,
    required this.ref,
  });

  final String userId;
  final WidgetRef ref;

  @override
  State<_EmailGateSheet> createState() => _EmailGateSheetState();
}

class _EmailGateSheetState extends State<_EmailGateSheet> {
  final _ctrl = TextEditingController();
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool _isValidEmail(String v) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
  }

  Future<void> _save() async {
    final email = _ctrl.text.trim();
    if (!_isValidEmail(email)) {
      setState(() {
        _error = 'Please enter a valid email address';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    final result = await widget.ref
        .read(profileRepositoryProvider)
        .updateEmail(widget.userId, email);

    if (!mounted) return;

    result.fold(
      (_) {
        setState(() {
          _isSaving = false;
          _error = 'Could not save. Please try again.';
        });
      },
      (_) {
        widget.ref.invalidate(currentUserProvider);
        Navigator.of(context).pop(email);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 32,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.borderSolid,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Text(
            'Add your email address',
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Your email is needed to send you a payment receipt. It will be '
            'saved to your profile for future payments.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 24),
          Text(
            'EMAIL ADDRESS',
            style: AppTextStyles.sectionLabel,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _ctrl,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'your@email.com',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
              errorText: _error,
              errorStyle: AppTextStyles.caption.copyWith(
                color: AppColors.danger,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.borderSolid,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.borderSolid,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.secondary,
                  width: 1.5,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Save & continue →',
                      style: AppTextStyles.buttonLarge,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
