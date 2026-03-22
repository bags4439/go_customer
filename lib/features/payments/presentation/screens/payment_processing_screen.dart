import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
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
        backgroundColor: const Color(0xFF1C1C1E),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const SizedBox.shrink(),
          title: const Text(
            'Processing',
            style: TextStyle(color: Colors.white, fontSize: 18),
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
                      ref.read(activePaymentProvider(orderId).notifier).state = null;
                      context.go(
                        '/order/$orderId/payment-request/$requestId/confirmed?paymentId=$paymentId',
                      );
                    });
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }
                  return _ProcessingBody(maskedPhone: 'XX XXX XXXX');
                },
                loading: () => _ProcessingBody(maskedPhone: 'XX XXX XXXX'),
                error: (e, _) => _TimeoutBody(
                  onTryAgain: () => ref.refresh(paymentStatusProvider(paymentId)),
                ),
              ),
      ),
    );
  }
}

class _ProcessingBody extends StatelessWidget {
  final String maskedPhone;

  const _ProcessingBody({required this.maskedPhone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 48),
          const Icon(Icons.phone_android, size: 80, color: Colors.white54),
          const SizedBox(height: 24),
          const Text(
            'Check your phone',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'A MoMo prompt has been sent to $maskedPhone',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 48),
          _StepItem(label: 'Payment request sent to network', done: true),
          _StepItem(label: 'Waiting for your PIN approval', active: true),
          _StepItem(label: 'Payment confirmed', done: false),
          _StepItem(label: 'Agent notified', done: false),
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
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondary),
            )
          else
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              color: done ? AppColors.success : (active ? Colors.white : Colors.white54),
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeoutBody extends StatelessWidget {
  final VoidCallback onTryAgain;

  const _TimeoutBody({required this.onTryAgain});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.schedule, size: 64, color: Colors.white54),
            const SizedBox(height: 16),
            const Text(
              'Taking longer than expected',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your payment may still be processing. You can try again or check your order for updates.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onTryAgain,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
