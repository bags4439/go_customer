import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/styled_snackbar.dart';
import '../../core/constants/order_edit_constants.dart';
import '../providers/order_providers.dart';
import '../../../clearance/presentation/providers/clearance_providers.dart';
import '../../../preferences/data/datasources/preferences_firestore_data_source.dart';
import '../../../../shared/providers/firebase_providers.dart';

const _kBorderColor = 0xFFE0DFD8;
const _kSurface = 0xFFF5F4F0;
const _kDanger = 0xFFE24B4A;
const _kSuccess = 0xFF1D9E75;
const _kSuccessText = 0xFF27500A;
const _kTextSecondary = 0xFF666666;
const _kAmberBg = 0xFFFAEEDA;
const _kAmberBorder = 0xFFBA7517;
const _kAmberText = 0xFF633806;

class OrderCancelScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderCancelScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderCancelScreen> createState() => _OrderCancelScreenState();
}

class _OrderCancelScreenState extends ConsumerState<OrderCancelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _cardController;
  late Animation<double> _cardSlide;
  late Animation<double> _buttonsOpacity;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _cardSlide = Tween<double>(
      begin: 0.3,
      end: 0,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));
    _buttonsOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _cardController,
        curve: const Interval(0.4, 1, curve: Curves.easeOut),
      ),
    );
    _cardController.forward();
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderProvider(widget.orderId));

    return orderAsync.when(
      data: (order) {
        if (order == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(OrderEditConstants.cancelOrderTitle),
            ),
            body: const Center(child: Text('Order not found')),
          );
        }
        if (order.firstPaymentMade) {
          return _AccessDeniedScreen(orderId: widget.orderId);
        }
        if (order.isCancelled || order.isCompleted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.go('/order/${widget.orderId}');
            }
          });
          return Scaffold(
            appBar: AppBar(
              title: const Text(OrderEditConstants.cancelOrderTitle),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        return _CancelContent(
          orderId: widget.orderId,
          orderRef: order.orderRef,
          status: order.status,
          cardSlide: _cardSlide,
          buttonsOpacity: _buttonsOpacity,
        );
      },
      loading: () => Scaffold(
        appBar: _buildAppBar(context),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        appBar: _buildAppBar(context),
        body: const Center(child: Text('Unable to load order')),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: Text(
        OrderEditConstants.cancelOrderTitle,
        style: AppTextStyles.titleMedium,
      ),
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(color: const Color(_kBorderColor), height: 0.5),
      ),
    );
  }
}

class _AccessDeniedScreen extends StatelessWidget {
  final String orderId;

  const _AccessDeniedScreen({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/order/$orderId'),
        ),
        title: Text(
          OrderEditConstants.cancelOrderTitle,
          style: AppTextStyles.titleMedium,
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(color: const Color(_kBorderColor), height: 0.5),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(_kSurface),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: Color(0xFFAAAAAA),
                ),
                const SizedBox(height: 16),
                Text(
                  OrderEditConstants.notAvailable,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  OrderEditConstants.accessDeniedMessage,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(_kTextSecondary),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.go('/order/$orderId'),
                    child: const Text(OrderEditConstants.backToOrder),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CancelContent extends ConsumerWidget {
  final String orderId;
  final String orderRef;
  final String status;
  final Animation<double> cardSlide;
  final Animation<double> buttonsOpacity;

  const _CancelContent({
    required this.orderId,
    required this.orderRef,
    required this.status,
    required this.cardSlide,
    required this.buttonsOpacity,
  });

  static String _statusLabel(String status) {
    const labels = {
      FirestoreEnumValues.orderStatusOpen: 'Open',
      FirestoreEnumValues.orderStatusAgentAssigned: 'Agent assigned',
      FirestoreEnumValues.orderStatusSearching: 'Searching',
      FirestoreEnumValues.orderStatusBidPlaced: 'Bid placed',
      FirestoreEnumValues.orderStatusBidWon: 'Bid won',
      FirestoreEnumValues.orderStatusBidLost: 'Bid lost',
      FirestoreEnumValues.orderStatusPaymentPending: 'Payment pending',
      FirestoreEnumValues.orderStatusPaymentReceived: 'Payment received',
      FirestoreEnumValues.orderStatusShipping: 'Shipping',
      FirestoreEnumValues.orderStatusArrived: 'Arrived',
      FirestoreEnumValues.orderStatusDutyPending: 'Duty pending',
      FirestoreEnumValues.orderStatusDutyPaid: 'Duty paid',
      FirestoreEnumValues.orderStatusClearanceInProgress: 'Clearance',
      FirestoreEnumValues.orderStatusClearanceComplete: 'Clearance complete',
      FirestoreEnumValues.orderStatusRepairPending: 'Repair pending',
      FirestoreEnumValues.orderStatusRepairInProgress: 'Repair in progress',
      FirestoreEnumValues.orderStatusRepairComplete: 'Repair complete',
      FirestoreEnumValues.orderStatusDelivered: 'Delivered',
      FirestoreEnumValues.orderStatusCancelled: 'Cancelled',
      FirestoreEnumValues.orderStatusDormant: 'Dormant',
    };
    return labels[status] ?? status;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentNameAsync = ref.watch(agentFirstNameProvider(orderId));
    final vehicleOptionsSent = ref.watch(vehicleOptionsSentProvider(orderId));
    final cancelState = ref.watch(cancelOrderNotifierProvider(orderId));
    final prefsAsync = ref.watch(_carPrefsForOrderProvider(orderId));
    final agentName = agentNameAsync.valueOrNull ?? 'Your agent';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          OrderEditConstants.cancelOrderTitle,
          style: AppTextStyles.titleMedium,
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(color: const Color(_kBorderColor), height: 0.5),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (vehicleOptionsSent.valueOrNull == true) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(_kAmberBg),
                  border: const Border(
                    left: BorderSide(color: Color(_kAmberBorder), width: 3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: Color(_kAmberBorder),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        OrderEditConstants.vehicleOptionsWarningCancel
                            .replaceAll('[agentFirstName]', agentName),
                        style: AppTextStyles.cardLabel.copyWith(
                          color: const Color(_kAmberText),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
            AnimatedBuilder(
              animation: cardSlide,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 80 * cardSlide.value),
                  child: child,
                );
              },
              child: prefsAsync.when(
                data: (prefs) => _OrderSummaryCard(
                  orderRef: orderRef,
                  make: prefs?['make'] as String? ?? '—',
                  model: prefs?['model'] as String? ?? '—',
                  yearMin: prefs?['yearMin'] as int? ?? 0,
                  yearMax: prefs?['yearMax'] as int? ?? 0,
                  agentName: agentName,
                  statusLabel: _statusLabel(status),
                ),
                loading: () => Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(_kSurface),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                ),
                error: (_, __) => _OrderSummaryCard(
                  orderRef: orderRef,
                  make: '—',
                  model: '—',
                  yearMin: 0,
                  yearMax: 0,
                  agentName: agentName,
                  statusLabel: _statusLabel(status),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3DE),
                border: const Border(
                  left: BorderSide(color: Color(_kSuccess), width: 3),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: Color(_kSuccess),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      OrderEditConstants.noChargeNote,
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(_kSuccessText),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: buttonsOpacity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: cancelState == CancelOrderStatus.cancelling
                          ? null
                          : () => _confirmCancel(context, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(_kDanger),
                        foregroundColor: Colors.white,
                      ),
                      child: cancelState == CancelOrderStatus.cancelling
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              OrderEditConstants.yesCancelButton,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(_kBorderColor)),
                        foregroundColor: const Color(_kTextSecondary),
                      ),
                      child: Text(
                        OrderEditConstants.noKeepOrderButton,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(cancelOrderNotifierProvider(orderId).notifier);
    final ok = await notifier.cancel();
    if (!context.mounted) return;
    if (ok) {
      context.go('/order/$orderId/cancelled');
    } else {
      showErrorSnackBar(context, OrderEditConstants.couldNotCancelSnackbar);
    }
  }
}

final _carPrefsForOrderProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, orderId) async {
      final ds = PreferencesFirestoreDataSource(ref.watch(firestoreProvider));
      return ds.getCarPreferences(orderId);
    });

class _OrderSummaryCard extends StatelessWidget {
  final String orderRef;
  final String make;
  final String model;
  final int yearMin;
  final int yearMax;
  final String agentName;
  final String statusLabel;

  const _OrderSummaryCard({
    required this.orderRef,
    required this.make,
    required this.model,
    required this.yearMin,
    required this.yearMax,
    required this.agentName,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    final carLabel = yearMin > 0 && yearMax > 0
        ? '$make $model $yearMin–$yearMax'
        : '$make $model';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(_kSurface),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            OrderEditConstants.cancelThisOrderHeading,
            style: AppTextStyles.titleSmall.copyWith(color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            OrderEditConstants.cancelSubtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(_kTextSecondary),
            ),
          ),
          const SizedBox(height: 14),
          Container(height: 0.5, color: const Color(_kBorderColor)),
          _SummaryRow(label: OrderEditConstants.orderLabel, value: orderRef),
          _SummaryRow(label: OrderEditConstants.carLabel, value: carLabel),
          _SummaryRow(label: OrderEditConstants.agentLabel, value: agentName),
          _SummaryRow(
            label: OrderEditConstants.statusLabel,
            value: statusLabel,
          ),
          _SummaryRow(
            label: OrderEditConstants.amountPaidLabel,
            value: OrderEditConstants.amountPaidZero,
            valueColor: const Color(_kSuccess),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.cardLabel.copyWith(
              color: const Color(_kTextSecondary),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.labelMedium.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}
