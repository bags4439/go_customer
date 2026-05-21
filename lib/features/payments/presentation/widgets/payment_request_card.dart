import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/providers/preferred_currency_provider.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../orders/core/constants/order_timeline_constants.dart';
import '../../../orders/presentation/widgets/order_detail/order_detail_web_navigation.dart';
import '../../data/models/payment_request_model.dart';

const _kBorder = 0xFFE0DFD8;
const _kPrimary = 0xFF378ADD;
const _kAmberBg = 0xFFFAEEDA;
const _kAmberText = 0xFF633806;
const _kTextSecondary = 0xFF666666;
const _kTextTertiary = 0xFFAAAAAA;
const _kSuccess = 0xFF1D9E75;
const _kDanger = 0xFFE24B4A;
const _kWarn = 0xFFBA7517;

/// Timeline-embedded payment request card with breakdown, invoice, deadline.
class PaymentRequestCard extends ConsumerStatefulWidget {
  final PaymentRequestModel paymentRequest;
  final String orderId;

  const PaymentRequestCard({
    super.key,
    required this.paymentRequest,
    required this.orderId,
  });

  @override
  ConsumerState<PaymentRequestCard> createState() =>
      _PaymentRequestCardState();
}

class _PaymentRequestCardState extends ConsumerState<PaymentRequestCard> {
  bool _breakdownExpanded = false;
  double _opacity = 0;
  bool _payLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _opacity = 1);
    });
  }

  String get _typeLabel =>
      FirestoreEnumValues.paymentRequestTypeLabels[widget
          .paymentRequest
          .type
          .firestoreValue] ??
      widget.paymentRequest.type.label;

  PaymentRequestModel get pr => widget.paymentRequest;

  Widget _deadlineRow(DateTime? deadline) {
    if (deadline == null) return const SizedBox.shrink();
    final now = DateTime.now();
    final diff = deadline.difference(now);
    final days = diff.inDays;
    Widget text;
    if (!diff.isNegative && diff.inHours < 24) {
      text = Text(
        OrderTimelineConstants.dueToday,
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w600,
          color: const Color(_kDanger),
        ),
      );
    } else if (days >= 0 && days < 5) {
      text = Text(
        OrderTimelineConstants.daysLeft.replaceAll('[n]', '$days'),
        style: AppTextStyles.labelSmall.copyWith(
          color: const Color(_kWarn),
        ),
      );
    } else {
      text = Text(
        DateFormatter.formatDateTime(deadline),
        style: AppTextStyles.caption.copyWith(
          color: const Color(_kTextTertiary),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          const Icon(Icons.schedule, size: 14, color: Color(_kTextTertiary)),
          const SizedBox(width: 6),
          Expanded(child: text),
        ],
      ),
    );
  }

  void _openInvoice(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(preferredCurrencyProvider);
    final display = CurrencyFormatter.formatForDisplay(
      usdAmount: pr.amountUsd,
      preferredCurrency: currency,
    );
    final hasBreakdown = pr.breakdown.isNotEmpty;

    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 200),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(_kBorder)),
                  ),
                ),
              ),
              const Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: ColoredBox(
                  color: Color(_kPrimary),
                  child: SizedBox(width: 3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 13, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            OrderTimelineConstants.paymentRequestLabel,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: const Color(_kTextTertiary),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(_kAmberBg),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            OrderTimelineConstants.awaitingPayment,
                            style: AppTextStyles.labelSmall.copyWith(
                              fontSize: 10,
                              color: const Color(_kAmberText),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _typeLabel,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Column(
                        key: ValueKey(pr.amountUsd),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            display.primary,
                            style: AppTextStyles.titleLarge.copyWith(
                              color: const Color(_kPrimary),
                            ),
                          ),
                          if (display.hasSecondary) ...[
                            const SizedBox(height: 2),
                            Text(
                              display.secondary!,
                              style: AppTextStyles.amountSmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (hasBreakdown) ...[
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => setState(
                          () => _breakdownExpanded = !_breakdownExpanded,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Text(
                                _breakdownExpanded
                                    ? OrderTimelineConstants.hideBreakdown
                                    : OrderTimelineConstants.seeBreakdown,
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: const Color(_kPrimary),
                                ),
                              ),
                              Icon(
                                _breakdownExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                size: 18,
                                color: const Color(_kPrimary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: _breakdownExpanded
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Divider(height: 16),
                                  ...pr.breakdown.map(
                                    (b) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              b.label,
                                              style: AppTextStyles.cardLabel
                                                  .copyWith(
                                                color: const Color(
                                                  _kTextSecondary,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            CurrencyFormatter.format(
                                              b.amountUsd * currency.usdToRate,
                                              currency,
                                            ),
                                            style: AppTextStyles.labelMedium
                                                .copyWith(
                                              color: b.isDeduction
                                                  ? const Color(_kSuccess)
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Divider(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total',
                                        style: AppTextStyles.cardValue,
                                      ),
                                      Text(
                                        display.primary,
                                        style: AppTextStyles.cardValue,
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                    if (pr.invoiceImageUrl != null &&
                        pr.invoiceImageUrl!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _openInvoice(context, pr.invoiceImageUrl!),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.receipt_outlined,
                              size: 14,
                              color: Color(_kTextTertiary),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                OrderTimelineConstants.invoiceAttached,
                                style: AppTextStyles.caption.copyWith(
                                  color: const Color(_kTextSecondary),
                                ),
                              ),
                            ),
                            Text(
                              OrderTimelineConstants.viewInvoice,
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w500,
                                color: const Color(_kPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    _deadlineRow(pr.deadlineAt),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _payLoading
                            ? null
                            : () async {
                                setState(() => _payLoading = true);
                                if (!context.mounted) return;
                                OrderDetailWebNavigation.openPaymentRequest(
                                  context,
                                  ref,
                                  orderId: widget.orderId,
                                  requestId: pr.id,
                                );
                                if (mounted) {
                                  setState(() => _payLoading = false);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(_kPrimary),
                          foregroundColor: Colors.white,
                        ),
                        child: _payLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                OrderTimelineConstants.payNowButton
                                    .replaceAll('[label]', _typeLabel)
                                    .replaceAll('[amount]', display.primary),
                                style: AppTextStyles.buttonLarge
                                    .copyWith(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
