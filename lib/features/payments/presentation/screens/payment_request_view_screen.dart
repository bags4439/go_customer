import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/providers/preferred_currency_provider.dart';
import '../../domain/entities/breakdown_item.dart';
import '../../domain/entities/payment_request.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../providers/payment_providers.dart';

class PaymentRequestViewScreen extends ConsumerWidget {
  final String orderId;
  final String requestId;

  const PaymentRequestViewScreen({
    super.key,
    required this.orderId,
    required this.requestId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestAsync = ref.watch(paymentRequestProvider(requestId));
    final agentAsync = ref.watch(agentForPaymentProvider(requestAsync.valueOrNull?.createdByAgentId ?? ''));
    final orderAsync = ref.watch(orderProvider(orderId));
    final orderRef = orderAsync.valueOrNull?.orderRef ?? orderId;

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
          'Payment request',
          style: TextStyle(color: Colors.black87, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                orderRef,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: requestAsync.when(
        data: (request) {
          if (request == null) {
            return const Center(child: Text('Payment request not found', style: TextStyle(color: Colors.black87)));
          }
          if (!request.isPending) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('This request is no longer pending', style: TextStyle(color: Colors.black87)),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go('/order/$orderId'),
                    child: const Text('View order'),
                  ),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AgentHeader(request: request, agentAsync: agentAsync),
                const SizedBox(height: 24),
                _AmountHero(request: request),
                const SizedBox(height: 24),
                _BreakdownSection(request: request),
                if (request.type == AppConstants.paymentRequestTypeVehicleBalanceAndShipping &&
                    request.depositDeductedGhs != null) ...[
                  const SizedBox(height: 16),
                  _DepositClarityNote(depositDeductedGhs: request.depositDeductedGhs!),
                ],
                if (request.type == AppConstants.paymentRequestTypeRepairFee) ...[
                  const SizedBox(height: 16),
                  _RepairFeeNote(),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => context.push(
                      '/order/$orderId/payment-request/$requestId/checkout',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Proceed to payment →'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/order/$orderId'),
                  child: const Text('View order details', style: TextStyle(color: Colors.black87)),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'PAYMENT REQUEST',
                    style: TextStyle(color: Colors.black38, fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.secondary)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.black87))),
      ),
    );
  }
}

class _AgentHeader extends ConsumerWidget {
  final PaymentRequest request;
  final AsyncValue<AgentDetailView?> agentAsync;

  const _AgentHeader({required this.request, required this.agentAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typeLabel = paymentRequestTypeLabel(request.type);
    final sentAt = request.sentAt != null
        ? DateFormat.jm().format(request.sentAt!)
        : 'Just now';

    return Row(
      children: [
        agentAsync.when(
          data: (agent) {
            return CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.secondary,
              child: Text(
                agent?.initials ?? '?',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            );
          },
          loading: () => const CircleAvatar(radius: 24, backgroundColor: Colors.grey),
          error: (_, __) => const CircleAvatar(radius: 24, backgroundColor: Colors.grey, child: Icon(Icons.person)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Request from ${agentAsync.valueOrNull?.fullName ?? 'Agent'}',
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 16),
              ),
              Text(
                typeLabel,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ],
          ),
        ),
        Text(sentAt, style: const TextStyle(color: Colors.black54, fontSize: 12)),
      ],
    );
  }
}

class _AmountHero extends ConsumerWidget {
  const _AmountHero({required this.request});

  final PaymentRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(preferredCurrencyProvider);
    final display = CurrencyFormatter.formatForDisplay(
      usdAmount: request.totalGhs,
      preferredCurrency: currency,
    );
    final deadlineWidget = request.deadlineAt != null
        ? _DeadlinePill(deadlineAt: request.deadlineAt!)
        : const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AMOUNT DUE',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textTertiary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          display.primary,
          style: GoogleFonts.dmSans(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (display.hasSecondary) ...[
          const SizedBox(height: 4),
          Text(
            display.secondary!,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 8),
        deadlineWidget,
      ],
    );
  }
}

class _DeadlinePill extends StatefulWidget {
  final DateTime deadlineAt;

  const _DeadlinePill({required this.deadlineAt});

  @override
  State<_DeadlinePill> createState() => _DeadlinePillState();
}

class _DeadlinePillState extends State<_DeadlinePill> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final diff = widget.deadlineAt.difference(now);
    final days = diff.inDays;
    final within24h = diff.inHours < 24;
    String label;
    if (days <= 0) {
      label = 'Pay today';
    } else if (days == 1) {
      label = 'Pay within 1 day';
    } else {
      label = 'Pay within $days days';
    }

    Widget pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
    );

    if (within24h) {
      pill = AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(opacity: 0.7 + 0.3 * _controller.value, child: child);
        },
        child: pill,
      );
    }
    return pill;
  }
}

class _BreakdownSection extends ConsumerWidget {
  final PaymentRequest request;

  const _BreakdownSection({required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(preferredCurrencyProvider);
    final totalPrimary = CurrencyFormatter.formatForDisplay(
      usdAmount: request.totalGhs,
      preferredCurrency: currency,
    ).primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BREAKDOWN',
          style: TextStyle(color: Colors.black54, fontSize: 12),
        ),
        const SizedBox(height: 12),
        ...request.breakdown.map((item) => _BreakdownRow(item: item)),
        const Divider(color: Color(0xFFE0DFD8), height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total due', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  totalPrimary,
                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 18),
                ),
                if (currency.code != 'USD')
                  Text(
                    '≈ ${CurrencyFormatter.formatUsd(request.totalGhs)}',
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _BreakdownRow extends ConsumerWidget {
  final BreakdownItem item;

  const _BreakdownRow({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(preferredCurrencyProvider);
    final isDeduction = item.isDeduction;
    final color = isDeduction ? AppColors.success : Colors.black87;

    final converted = item.amountGhs * currency.usdToRate;
    final formattedStr = isDeduction
        ? '−${CurrencyFormatter.format(converted, currency)}'
        : CurrencyFormatter.format(converted, currency);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              item.label,
              style: TextStyle(color: color, fontSize: 14),
            ),
          ),
          Text(
            formattedStr,
            style: TextStyle(color: color, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _DepositClarityNote extends ConsumerWidget {
  final double depositDeductedGhs;

  const _DepositClarityNote({required this.depositDeductedGhs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(preferredCurrencyProvider);
    final depositFormatted = CurrencyFormatter.format(
      depositDeductedGhs * currency.usdToRate,
      currency,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: const Border(left: BorderSide(color: AppColors.success, width: 4)),
      ),
      child: Text(
        'Your 10% deposit of $depositFormatted has been deducted from the vehicle purchase price. You are only paying the remaining balance.',
        style: const TextStyle(color: Colors.black87, fontSize: 14),
      ),
    );
  }
}

class _RepairFeeNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: const Border(left: BorderSide(color: AppColors.secondary, width: 4)),
      ),
      child: const Text(
        'Garage name and approved quote reference are shown in the breakdown above.',
        style: TextStyle(color: Colors.black87, fontSize: 14),
      ),
    );
  }
}
