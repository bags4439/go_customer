import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/services/payment_cloud_service.dart';
import '../../data/services/paystack_payment_service.dart'
    show launchPaystackCheckout;
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
  ConsumerState<PaymentMethodScreen> createState() =>
      _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends ConsumerState<PaymentMethodScreen> {
  bool _paying = false;

  @override
  Widget build(BuildContext context) {
    final requestAsync = ref.watch(paymentRequestProvider(widget.requestId));

    return requestAsync.when(
      data: (request) {
        if (request == null || !request.isPending) {
          return Scaffold(
            appBar: AppBar(title: const Text('Payment summary')),
            body: const Center(
              child: Text('Request not found or no longer pending'),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              'Payment summary',
              style: TextStyle(color: Colors.black87, fontSize: 18),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PaymentTypeCard(
                  request: request,
                  exchangeRate: request.exchangeRateAtRequest,
                ),
                const SizedBox(height: 16),
                if (request.breakdown.isNotEmpty)
                  _BreakdownCard(request: request),
                const SizedBox(height: 16),
                _TotalCard(request: request),
                if (request.deadlineAt != null) ...[
                  const SizedBox(height: 12),
                  _DeadlineCard(deadline: request.deadlineAt!),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Text('Secured by Paystack', style: AppTextStyles.caption),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _paying ? null : () => _onConfirmAndPay(request),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.secondary.withValues(
                        alpha: 0.6,
                      ),
                      elevation: 0,
                    ),
                    child: _paying
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Pay GHS ${_formatGhs(request.amountUsd * request.exchangeRateAtRequest)} →',
                            style: AppTextStyles.buttonLarge,
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Payment summary')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Payment summary')),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  String _formatGhs(double amount) {
    return amount.toStringAsFixed(2);
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _EmailGateSheet(userId: user.id, ref: ref),
    );
    return email;
  }

  Future<void> _onConfirmAndPay(PaymentRequest request) async {
    if (_paying) return;
    setState(() => _paying = true);

    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) {
        if (mounted) {
          _showError('Could not load your profile. Please try again.');
        }
        return;
      }

      if (!mounted) return;
      final email = await _ensureEmail(context, ref, user);
      if (email == null || email.trim().isEmpty) {
        return;
      }

      if (!mounted) return;
      late final PaystackInitResult result;
      try {
        result = await ref
            .read(paymentCloudServiceProvider)
            .initializeTransaction(
              orderId: widget.orderId,
              requestId: widget.requestId,
              email: email.trim(),
            );
      } on FirebaseFunctionsException catch (e) {
        if (mounted) {
          _showError(
            e.message ?? 'Could not initialize payment. Please try again.',
          );
        }
        return;
      } catch (_) {
        if (mounted) {
          _showError('Could not initialize payment. Please try again.');
        }
        return;
      }

      ref.read(paymentTimeoutProvider.notifier).start(result.paymentId);

      if (!mounted) return;
      final checkoutOpened = await launchPaystackCheckout(
        context: context,
        authorizationUrl: result.authorizationUrl,
        reference: result.reference,
        customerEmail: email.trim(),
        amountGhs: result.amountGhs,
      );

      if (!mounted) return;
      if (!checkoutOpened) {
        ref.read(paymentTimeoutProvider.notifier).reset();
        _showError(
          'Could not open Paystack checkout. '
          'Allow pop-ups for this site and try again.',
        );
        return;
      }

      context.push(
        '/order/${widget.orderId}/payment-request/${widget.requestId}/processing?paymentId=${result.paymentId}',
      );
    } finally {
      if (mounted) {
        setState(() => _paying = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }
}

class _EmailGateSheet extends StatefulWidget {
  const _EmailGateSheet({required this.userId, required this.ref});

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
          Text('Add your email address', style: AppTextStyles.titleSmall),
          const SizedBox(height: 8),
          Text(
            'Your email is needed to send you a payment receipt. It will be '
            'saved to your profile for future payments.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 24),
          Text('EMAIL ADDRESS', style: AppTextStyles.sectionLabel),
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
                borderSide: const BorderSide(color: AppColors.borderSolid),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderSolid),
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
                  : Text('Save & continue →', style: AppTextStyles.buttonLarge),
            ),
          ),
        ],
      ),
    );
  }
}

/// Displays the payment type and description.
class _PaymentTypeCard extends StatelessWidget {
  const _PaymentTypeCard({required this.request, required this.exchangeRate});

  final PaymentRequest request;
  final double exchangeRate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSolid, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            paymentRequestTypeLabel(request.type),
            style: AppTextStyles.titleSmall,
          ),
          if (request.description != null &&
              request.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(request.description!, style: AppTextStyles.bodySmall),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.currency_exchange,
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                '1 USD = GHS ${exchangeRate.toStringAsFixed(2)}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Displays the breakdown items.
class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({required this.request});

  final PaymentRequest request;

  @override
  Widget build(BuildContext context) {
    final rate = request.exchangeRateAtRequest;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSolid, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('BREAKDOWN', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 10),
          ...request.breakdown.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(item.label, style: AppTextStyles.bodySmall),
                  ),
                  Text(
                    '${item.isDeduction ? '-' : ''}GHS ${(item.amountUsd * rate).toStringAsFixed(2)}',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: item.isDeduction
                          ? AppColors.success
                          : AppColors.textPrimary,
                    ),
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

/// Displays the total amount prominently.
class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.request});

  final PaymentRequest request;

  @override
  Widget build(BuildContext context) {
    final totalGhs = request.amountUsd * request.exchangeRateAtRequest;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.infoBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total', style: AppTextStyles.titleSmall),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'GHS ${totalGhs.toStringAsFixed(2)}',
                style: AppTextStyles.amountMedium.copyWith(
                  color: AppColors.secondary,
                ),
              ),
              Text(
                'USD ${request.amountUsd.toStringAsFixed(2)}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shows the payment deadline.
class _DeadlineCard extends StatelessWidget {
  const _DeadlineCard({required this.deadline});

  final DateTime deadline;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isUrgent = deadline.difference(now).inHours < 24;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUrgent ? AppColors.amberBackground : AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isUrgent ? AppColors.warning : AppColors.borderSolid,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            size: 16,
            color: isUrgent ? AppColors.warning : AppColors.textTertiary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Pay before ${_formatDeadline(deadline)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: isUrgent ? AppColors.warning : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDeadline(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
