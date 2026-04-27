part of '../screens/home_screen.dart';

class _OriginPill extends StatelessWidget {
  final String origin;

  const _OriginPill({required this.origin});

  @override
  Widget build(BuildContext context) {
    final (String label, Color bg, Color text) = switch (origin) {
      'us_canada' => ('🇺🇸 US / Canada', _C.pillSoftBlue, _C.infoText),
      'dubai' => ('🇦🇪 Dubai', _C.warningBg, _C.amberText),
      'china' => ('🇨🇳 China', _C.successBg, _C.successMutedForeground),
      _ => (origin, _C.bgSecondary, _C.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(fontSize: 10, color: text),
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final OrderView order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter.of(context);
    final paymentAsync = ref.watch(activePaymentRequestProvider(order.id));

    final accentColor = order.needsPayment
        ? _C.danger
        : order.isCompleted
        ? _C.success
        : _C.primary;

    final progress = (order.stageNumber.clamp(1, 9)) / 9.0;
    const radius = 14.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: _C.bgPrimary,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: () => router.push('/order/${order.id}'),
          borderRadius: BorderRadius.circular(radius),
          splashColor: _C.infoBg,
          highlightColor: _C.bgSecondary,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: _C.border, width: 0.5),
              borderRadius: BorderRadius.circular(radius),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 5,
                      color: accentColor,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        accentColor.withValues(alpha: 0.15),
                                        accentColor.withValues(alpha: 0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: accentColor.withValues(alpha: 0.2),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.directions_car_filled,
                                    size: 22,
                                    color: accentColor,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${order.make ?? 'Vehicle'} ${order.model ?? ''}'
                                            .trim(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.labelLarge,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        order.orderRef,
                                        style: _ts(
                                          size: 11,
                                          color: _C.textTertiary,
                                        ),
                                      ),
                                      if (order.purchaseOrigin != 'any') ...[
                                        const SizedBox(height: 4),
                                        _OriginPill(
                                          origin: order.purchaseOrigin,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                _StatusBadge(order: order),
                              ],
                            ),
                            const SizedBox(height: 10),
                            paymentAsync.when(
                              data: (p) {
                                if (p == null) {
                                  return Text(
                                    _homeStatusDescription(order),
                                    style: _ts(
                                      size: 12,
                                      color: _C.textSecondary,
                                    ),
                                  );
                                }
                                return _PaymentInlineCta(
                                  payment: p,
                                  orderId: order.id,
                                );
                              },
                              loading: () => const SizedBox(height: 14),
                              error: (_, __) => Text(
                                _homeStatusDescription(order),
                                style: _ts(size: 12, color: _C.textSecondary),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 6,
                                      backgroundColor: _C.border,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        accentColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Step ${order.stageNumber} of 9',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: _C.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _homeStatusDescription(OrderView order) {
  if (order.needsPayment) return 'Payment required to continue';
  if (order.isCompleted) return 'Delivered · order complete';
  if (order.isCancelled) return 'This order was cancelled';

  switch (order.status) {
    case FirestoreEnumValues.orderStatusOpen:
      return 'Submitted · matching you with an agent';
    case FirestoreEnumValues.orderStatusAgentAssigned:
      if (order.isNewVehicle) {
        return 'Agent contacting suppliers in China';
      }
      return switch (order.purchaseOrigin) {
        'us_canada' => 'Agent searching US auctions',
        'dubai' => 'Agent sourcing from Dubai',
        'china' => 'Agent contacting China dealers',
        _ => 'Your agent is on it',
      };
    case FirestoreEnumValues.orderStatusSearching:
      return switch (order.purchaseOrigin) {
        'us_canada' => 'Searching US & Canada auctions',
        'dubai' => 'Sourcing options from Dubai',
        'china' => 'Searching China dealers',
        _ => 'Searching for your vehicle',
      };
    case FirestoreEnumValues.orderStatusBidPlaced:
      return 'A bid is live on your chosen vehicle';
    case FirestoreEnumValues.orderStatusBidWon:
      return 'Vehicle secured · next steps in chat';
    case FirestoreEnumValues.orderStatusBidLost:
      return 'Could not secure vehicle · agent will suggest options';
    case FirestoreEnumValues.orderStatusPaymentReceived:
      return 'Payment received · moving to shipping';
    case FirestoreEnumValues.orderStatusShipping:
      return '🚢 Your car is in transit';
    case FirestoreEnumValues.orderStatusArrived:
      return 'Vehicle arrived · customs & clearance next';
    case FirestoreEnumValues.orderStatusDutyPending:
      return 'Import duty assessment in progress';
    case FirestoreEnumValues.orderStatusDutyPaid:
      return 'Duty paid · clearance in progress';
    case FirestoreEnumValues.orderStatusClearanceInProgress:
      return 'Port clearance in progress';
    case FirestoreEnumValues.orderStatusClearanceComplete:
      return 'Clearance complete';
    case FirestoreEnumValues.orderStatusRepairPending:
      return 'Repairs pending your confirmation';
    case FirestoreEnumValues.orderStatusRepairInProgress:
      return 'Repairs in progress';
    case FirestoreEnumValues.orderStatusRepairComplete:
      return 'Repairs complete · delivery next';
    case FirestoreEnumValues.orderStatusDormant:
    default:
      return 'No recent activity · open chat if needed';
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderView order;

  const _StatusBadge({required this.order});

  @override
  Widget build(BuildContext context) {
    late String label;
    late Color bg;
    late Color text;

    if (order.needsPayment) {
      label = 'Pay now';
      bg = _C.dangerBg;
      text = _C.danger;
    } else if (order.isCompleted) {
      label = 'Delivered';
      bg = _C.successBg;
      text = _C.success;
    } else {
      switch (order.status) {
        case FirestoreEnumValues.orderStatusOpen:
          label = 'Submitted';
          bg = _C.bgSecondary;
          text = _C.textSecondary;
          break;
        case FirestoreEnumValues.orderStatusAgentAssigned:
          label = 'Agent assigned';
          bg = _C.infoBg;
          text = _C.infoText;
          break;
        case FirestoreEnumValues.orderStatusSearching:
          label = 'Searching';
          bg = _C.warningBg;
          text = _C.warning;
          break;
        case FirestoreEnumValues.orderStatusBidPlaced:
          label = 'Bid placed';
          bg = _C.warningBg;
          text = _C.warning;
          break;
        case FirestoreEnumValues.orderStatusBidWon:
          label = 'Won auction';
          bg = _C.successBg;
          text = _C.success;
          break;
        case FirestoreEnumValues.orderStatusBidLost:
          label = 'Bid lost';
          bg = _C.dangerBg;
          text = _C.danger;
          break;
        case FirestoreEnumValues.orderStatusPaymentReceived:
          label = 'Paid';
          bg = _C.successBg;
          text = _C.success;
          break;
        case FirestoreEnumValues.orderStatusShipping:
          label = 'Shipping';
          bg = _C.infoBg;
          text = _C.infoText;
          break;
        case FirestoreEnumValues.orderStatusArrived:
          label = 'Arrived';
          bg = _C.successBg;
          text = _C.success;
          break;
        case FirestoreEnumValues.orderStatusDutyPending:
          label = 'Duty pending';
          bg = _C.warningBg;
          text = _C.warning;
          break;
        case FirestoreEnumValues.orderStatusDutyPaid:
          label = 'Duty paid';
          bg = _C.infoBg;
          text = _C.infoText;
          break;
        case FirestoreEnumValues.orderStatusClearanceInProgress:
          label = 'Clearance';
          bg = _C.infoBg;
          text = _C.infoText;
          break;
        case FirestoreEnumValues.orderStatusClearanceComplete:
          label = 'Cleared';
          bg = _C.successBg;
          text = _C.success;
          break;
        case FirestoreEnumValues.orderStatusRepairPending:
          label = 'Repairs';
          bg = _C.warningBg;
          text = _C.warning;
          break;
        case FirestoreEnumValues.orderStatusRepairInProgress:
          label = 'In repair';
          bg = _C.warningBg;
          text = _C.warning;
          break;
        case FirestoreEnumValues.orderStatusRepairComplete:
          label = 'Repairs done';
          bg = _C.successBg;
          text = _C.success;
          break;
        case FirestoreEnumValues.orderStatusCancelled:
          label = 'Cancelled';
          bg = _C.dangerBg;
          text = _C.danger;
          break;
        case FirestoreEnumValues.orderStatusDormant:
          label = 'On hold';
          bg = _C.bgSecondary;
          text = _C.textSecondary;
          break;
        default:
          label = 'In progress';
          bg = _C.bgSecondary;
          text = _C.textSecondary;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: _ts(size: 10, weight: FontWeight.w500, color: text),
      ),
    );
  }
}

class _PaymentInlineCta extends ConsumerWidget {
  final PaymentRequestView payment;
  final String orderId;

  const _PaymentInlineCta({required this.payment, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(preferredCurrencyProvider);
    final display = CurrencyFormatter.formatForDisplay(
      usdAmount: payment.amountUsd,
      preferredCurrency: currency,
    );

    return Container(
      decoration: BoxDecoration(
        color: _C.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  display.primary,
                  style: _ts(
                    size: 14,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (display.hasSecondary) ...[
                  const SizedBox(height: 1),
                  Text(
                    display.secondary!,
                    style: _ts(
                      size: 10,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  FirestoreEnumValues.paymentRequestTypeLabels[payment.type] ??
                      payment.type,
                  style: _ts(
                    size: 11,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => GoRouter.of(
              context,
            ).push('/order/$orderId/payment-request/${payment.id}'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _C.bgPrimary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Pay now',
                style: _ts(
                  size: 12,
                  weight: FontWeight.w600,
                  color: _C.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
