import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/payment_providers.dart';

class PaymentProcessingScreen extends ConsumerWidget {
  final String orderId;
  final String requestId;
  final String paymentId;

  const PaymentProcessingScreen({
    super.key,
    required this.orderId,
    required this.requestId,
    required this.paymentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentAsync = ref.watch(paymentStatusProvider(paymentId));
    final timeoutState = ref.watch(paymentTimeoutProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const SizedBox.shrink(),
          title: const Text(
            'Processing',
            style: TextStyle(color: Colors.black87, fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: timeoutState.isTimedOut
            ? _TimeoutBody(
                onTryAgain: () {
                  ref.read(paymentTimeoutProvider.notifier).reset();
                  ref.read(paymentTimeoutProvider.notifier).start(paymentId);
                },
              )
            : paymentAsync.when(
                data: (payment) {
                  if (payment?.isConfirmed == true) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ref.read(paymentTimeoutProvider.notifier).reset();
                      ref.read(activePaymentProvider(orderId).notifier).state =
                          null;
                      context.go(
                        '/order/$orderId/payment-request/$requestId/confirmed?paymentId=$paymentId',
                      );
                    });
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.secondary,
                      ),
                    );
                  }
                  return const _ProcessingBody();
                },
                loading: () => const _ProcessingBody(),
                error: (e, _) => _TimeoutBody(
                  onTryAgain: () =>
                      ref.refresh(paymentStatusProvider(paymentId)),
                ),
              ),
      ),
    );
  }
}

class _ProcessingBody extends StatelessWidget {
  const _ProcessingBody();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Column(
        children: [
          const SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Confirming your payment',
            style: AppTextStyles.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we confirm your payment. This usually takes a few seconds.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          const _StepItem(label: 'Payment submitted to Paystack', done: true),
          const _StepItem(label: 'Awaiting confirmation', active: true),
          const _StepItem(label: 'Payment confirmed'),
          const _StepItem(label: 'Agent notified'),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String label;
  final bool done;
  final bool active;

  const _StepItem({
    required this.label,
    this.done = false,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          if (done)
            const Icon(Icons.check_circle, color: AppColors.success, size: 24)
          else if (active)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.secondary,
              ),
            )
          else
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFFE0DFD8),
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              color: done
                  ? AppColors.success
                  : (active ? Colors.black87 : Colors.black54),
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeoutBody extends StatelessWidget {
  const _TimeoutBody({required this.onTryAgain});

  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.schedule_rounded,
              size: 56,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'Taking longer than expected',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'If you completed the payment, it will be confirmed shortly and your order will update automatically. You can safely go back to your orders.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTryAgain,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: const Text('Check again'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/home'),
              child: Text(
                'Go to my orders',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
