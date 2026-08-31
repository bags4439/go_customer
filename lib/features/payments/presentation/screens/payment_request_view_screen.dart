import 'package:cloud_functions/cloud_functions.dart';
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
import '../../data/services/payment_cloud_service.dart';
import '../../data/services/paystack_payment_service.dart'
    show launchPaystackCheckout;
import '../../domain/entities/payment_request.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/layout/dashboard_layout.dart';
import '../../../../core/widgets/standalone_mobile_screen_scaffold.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../../orders/presentation/widgets/order_detail/order_detail_web_navigation.dart';
import '../../../orders/presentation/widgets/order_detail/order_detail_web_panel_chrome.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../providers/payment_providers.dart';

class PaymentRequestViewScreen extends ConsumerStatefulWidget {
  final String orderId;
  final String requestId;
  final bool embedInWebPanel;
  final VoidCallback? onClosePanel;

  const PaymentRequestViewScreen({
    super.key,
    required this.orderId,
    required this.requestId,
    this.embedInWebPanel = false,
    this.onClosePanel,
  });

  @override
  ConsumerState<PaymentRequestViewScreen> createState() =>
      _PaymentRequestViewScreenState();
}

class _PaymentRequestViewScreenState
    extends ConsumerState<PaymentRequestViewScreen> {
  bool _paying = false;

  @override
  Widget build(BuildContext context) {
    final requestAsync = ref.watch(paymentRequestProvider(widget.requestId));
    final agentAsync = ref.watch(
      agentForPaymentProvider(requestAsync.valueOrNull?.createdByAgentId ?? ''),
    );
    final orderAsync = ref.watch(orderProvider(widget.orderId));
    final orderRef = orderAsync.valueOrNull?.orderRef ?? widget.orderId;

    final body = requestAsync.when(
        data: (request) {
          if (request == null) {
            return Center(
              child: Text(
                'Payment request not found',
                style: AppTextStyles.bodyMedium,
              ),
            );
          }
          if (!request.isPending) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'This request is no longer pending',
                    style: AppTextStyles.bodyMedium,
                  ),
                  if (!widget.embedInWebPanel) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.go('/order/${widget.orderId}'),
                      child: const Text('View order'),
                    ),
                  ],
                ],
              ),
            );
          }

          final currency = ref.watch(preferredCurrencyProvider);

          // GHS is always the payment currency — Paystack only accepts GHS
          // regardless of the customer's preferred display currency.
          // We always show GHS as the primary amount.
          final ghsCurrency = CurrencyModel(
            code: 'GHS',
            symbol: 'GHS',
            name: 'Ghanaian Cedi',
            usdToRate:
                currency.code == 'GHS' ? currency.usdToRate : 15.4,
            decimalDigits: 0,
          );

          // We will update ghsRate from the currencies provider — for now use
          // the preferred currency rate if GHS, else fallback
          final ghsDisplay = CurrencyFormatter.formatForDisplay(
            usdAmount: request.amountUsd,
            preferredCurrency: ghsCurrency,
          );

          // Preferred currency display shown as secondary if it differs from GHS
          final preferredDisplay = currency.code == 'GHS'
              ? null
              : CurrencyFormatter.format(
                  request.amountUsd * currency.usdToRate,
                  currency,
                );

          return SingleChildScrollView(
            padding: DashboardLayout.flowScrollPadding(
              context,
              top: 16,
              bottom: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroCard(
                  request: request,
                  agentAsync: agentAsync,
                  ghsDisplay: ghsDisplay,
                  preferredDisplay: preferredDisplay,
                ),
                const SizedBox(height: 12),
                _BreakdownCard(request: request, ghsCurrency: ghsCurrency),
                const SizedBox(height: 8),
                _ExchangeRateNote(
                  ghsCurrency: ghsCurrency,
                  amountUsd: request.amountUsd,
                ),
                if (request.type ==
                        AppConstants
                            .paymentRequestTypeVehicleBalanceAndShipping &&
                    request.depositDeductedUsd != null) ...[
                  const SizedBox(height: 12),
                  _DepositClarityNote(
                    depositDeductedUsd: request.depositDeductedUsd!,
                  ),
                ],
                if (request.type ==
                    AppConstants.paymentRequestTypeRepairFee) ...[
                  const SizedBox(height: 12),
                  _RepairFeeNote(),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 12,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Secured by Paystack · 256-bit encryption',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
                if (widget.embedInWebPanel) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Paystack opens in a popup. Complete payment there — '
                    'this order updates automatically.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Text('Choose how to pay', style: AppTextStyles.titleMedium),
                const SizedBox(height: 10),
                _PaymentMethodCard(
                  icon: Icons.credit_card_rounded,
                  title: 'Pay online',
                  subtitle: 'Instant confirmation with secure Paystack checkout',
                  trailing: ghsDisplay.primary,
                  isPrimary: true,
                  isLoading: _paying,
                  onTap: _paying ? null : () => _onPay(request),
                ),
                const SizedBox(height: 10),
                _PaymentMethodCard(
                  icon: Icons.account_balance_rounded,
                  title: 'Bank transfer',
                  subtitle: 'Use bank details and download a transfer invoice',
                  onTap: _paying
                      ? null
                      : () => OrderDetailWebNavigation.openBankTransfer(
                            context,
                            ref,
                            orderId: widget.orderId,
                            requestId: widget.requestId,
                          ),
                ),
                if (!widget.embedInWebPanel) ...[
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/order/${widget.orderId}'),
                      child: Text(
                        'View order details',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.secondary),
        ),
        error: (e, _) =>
            Center(child: Text('Error: $e', style: AppTextStyles.bodyMedium)),
      );

    if (widget.embedInWebPanel) {
      return OrderDetailWebPanelChrome(
        title: 'Payment request',
        orderRef: orderRef,
        onBack: widget.onClosePanel ?? () {},
        child: body,
      );
    }

    return StandaloneMobileScreenScaffold(
      title: 'Payment request',
      onBack: () => context.pop(),
      actions: [standaloneOrderRefTrailing(orderRef)],
      body: body,
    );
  }

  Future<void> _onPay(PaymentRequest request) async {
    if (_paying) return;
    setState(() => _paying = true);

    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) {
        _showError('Could not load your profile. Please try again.');
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
          'Could not open the Paystack popup. '
          'Allow pop-ups for this site and try again.',
        );
        return;
      }

      if (AppBreakpoints.useWebShell(context)) {
        OrderDetailWebNavigation.openPaymentProcessing(
          ref,
          orderId: widget.orderId,
          requestId: widget.requestId,
          paymentId: result.paymentId,
        );
      } else {
        context.push(
          '/order/${widget.orderId}/payment-request/${widget.requestId}/processing?paymentId=${result.paymentId}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _paying = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
    this.isPrimary = false,
    this.isLoading = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final String? trailing;
  final bool isPrimary;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final foreground = isPrimary ? Colors.white : AppColors.textPrimary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.brand : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isPrimary ? AppColors.brand : AppColors.borderSolid,
            ),
            boxShadow: [
              BoxShadow(
                color: isPrimary
                    ? AppColors.brand.withValues(alpha: 0.22)
                    : Colors.black.withValues(alpha: 0.035),
                blurRadius: isPrimary ? 18 : 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isPrimary
                      ? Colors.white.withValues(alpha: 0.16)
                      : AppColors.brandMuted,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        icon,
                        color: isPrimary ? Colors.white : AppColors.brand,
                      ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTextStyles.titleSmall.copyWith(
                              color: foreground,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (trailing != null)
                          Text(
                            trailing!,
                            style: AppTextStyles.titleSmall.copyWith(
                              color: foreground,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: isPrimary
                            ? Colors.white.withValues(alpha: 0.78)
                            : AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                size: 20,
                color: isPrimary
                    ? Colors.white.withValues(alpha: 0.85)
                    : AppColors.brand,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hero card showing agent info, amount due and deadline.
class _HeroCard extends ConsumerWidget {
  const _HeroCard({
    required this.request,
    required this.agentAsync,
    required this.ghsDisplay,
    this.preferredDisplay,
  });

  final PaymentRequest request;
  final AsyncValue<AgentDetailView?> agentAsync;
  final CurrencyDisplay ghsDisplay;
  /// Non-null only when preferred currency differs from GHS
  final String? preferredDisplay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentAt = request.sentAt != null
        ? DateFormat.jm().format(request.sentAt!)
        : 'Just now';

    final typeLabel = paymentRequestTypeLabel(request.type);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSolid, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                agentAsync.when(
                  data: (agent) => CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.secondary,
                    child: Text(
                      agent?.initials ?? '?',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  loading: () => const CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.borderSolid,
                  ),
                  error: (_, __) => const CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.borderSolid,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Request from ${agentAsync.valueOrNull?.fullName ?? 'Agent'}',
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(sentAt, style: AppTextStyles.caption),
                    ],
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 0.5, color: AppColors.backgroundSecondary),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AMOUNT DUE', style: AppTextStyles.sectionLabel),
                const SizedBox(height: 6),
                // GHS amount — always primary regardless of preferred currency
                Text(
                  ghsDisplay.primary,
                  style: AppTextStyles.displaySmall.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Preferred currency badge if not GHS
                    if (preferredDisplay != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.borderSolid,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          '≈ $preferredDisplay',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    // USD secondary
                    Text(
                      '≈ ${CurrencyFormatter.formatUsd(request.amountUsd)}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (request.deadlineAt != null)
                  _DeadlinePill(deadlineAt: request.deadlineAt!),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.infoBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.credit_card_rounded,
                      size: 15,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      typeLabel,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
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

class _DeadlinePill extends StatefulWidget {
  final DateTime deadlineAt;

  const _DeadlinePill({required this.deadlineAt});

  @override
  State<_DeadlinePill> createState() => _DeadlinePillState();
}

class _DeadlinePillState extends State<_DeadlinePill>
    with SingleTickerProviderStateMixin {
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
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
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

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({required this.request, required this.ghsCurrency});

  final PaymentRequest request;
  final CurrencyModel ghsCurrency;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSolid, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Text('BREAKDOWN', style: AppTextStyles.sectionLabel),
          ),
          Container(height: 0.5, color: AppColors.backgroundSecondary),
          ...request.breakdown.map((item) {
            final converted = item.amountUsd * ghsCurrency.usdToRate;
            final formatted = item.isDeduction
                ? '−${CurrencyFormatter.format(converted, ghsCurrency)}'
                : CurrencyFormatter.format(converted, ghsCurrency);
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.label,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: item.isDeduction
                                ? AppColors.success
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        formatted,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: item.isDeduction
                              ? AppColors.success
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 0.5,
                  color: AppColors.backgroundSecondary,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ],
            );
          }),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total due', style: AppTextStyles.titleSmall),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(
                        request.amountUsd * ghsCurrency.usdToRate,
                        ghsCurrency,
                      ),
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (ghsCurrency.code != 'USD')
                      Text(
                        '≈ ${CurrencyFormatter.formatUsd(request.amountUsd)}',
                        style: AppTextStyles.caption,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DepositClarityNote extends ConsumerWidget {
  final double depositDeductedUsd;

  const _DepositClarityNote({required this.depositDeductedUsd});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(preferredCurrencyProvider);
    final depositFormatted = CurrencyFormatter.format(
      depositDeductedUsd * currency.usdToRate,
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
        border: const Border(
          left: BorderSide(color: AppColors.secondary, width: 4),
        ),
      ),
      child: const Text(
        'Garage name and approved quote reference are shown in the breakdown above.',
        style: TextStyle(color: Colors.black87, fontSize: 14),
      ),
    );
  }
}

class _ExchangeRateNote extends StatelessWidget {
  const _ExchangeRateNote({
    required this.ghsCurrency,
    required this.amountUsd,
  });

  final CurrencyModel ghsCurrency;
  final double amountUsd;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'USD ${amountUsd.toStringAsFixed(2)} equivalent at '
          '${ghsCurrency.usdToRate.toStringAsFixed(2)} GHS per USD',
      child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.currency_exchange_rounded,
            size: 12,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '1 USD = GHS ${ghsCurrency.usdToRate.toStringAsFixed(2)}'
              ' · Payment processed in GHS',
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    ),
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
            child: FilledButton(
              onPressed: _isSaving ? null : _save,
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
