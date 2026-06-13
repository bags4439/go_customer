import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_button_styles.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/card_container.dart';
import '../../../../core/widgets/styled_snackbar.dart';
import '../../../../shared/providers/firebase_providers.dart';
import '../../core/constants/order_edit_constants.dart';
import '../../core/utils/order_status_label.dart';
import '../../../clearance/presentation/providers/clearance_providers.dart';
import '../../../preferences/data/datasources/preferences_firestore_data_source.dart';
import '../providers/order_providers.dart';
import '../widgets/cancel/cancel_agent_contact_section.dart';
import '../widgets/order_flow_scaffold.dart';

class OrderCancelScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderCancelScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderCancelScreen> createState() => _OrderCancelScreenState();
}

class _OrderCancelScreenState extends ConsumerState<OrderCancelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _fade = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
        );
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  void _onBack() => context.pop();

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderProvider(widget.orderId));

    return orderAsync.when(
      data: (order) {
        if (order == null) {
          return OrderFlowScaffold(
            title: OrderEditConstants.cancelOrderTitle,
            onBack: _onBack,
            child: OrderFlowMessageBody(
              icon: Icons.inventory_2_outlined,
              title: OrderEditConstants.orderNotAvailableTitle,
              message: OrderEditConstants.orderNotAvailableBody,
              action: _BackToOrderButton(orderId: widget.orderId),
            ),
          );
        }
        if (order.firstPaymentMade) {
          return OrderFlowScaffold(
            title: OrderEditConstants.cancelOrderTitle,
            onBack: () => context.go('/order/${widget.orderId}'),
            child: OrderFlowMessageBody(
              icon: Icons.lock_outline_rounded,
              title: OrderEditConstants.notAvailable,
              message: OrderEditConstants.accessDeniedMessage,
              action: _BackToOrderButton(orderId: widget.orderId),
            ),
          );
        }
        if (order.isCancelled || order.isCompleted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.go('/order/${widget.orderId}');
          });
          return OrderFlowScaffold(
            title: OrderEditConstants.cancelOrderTitle,
            onBack: _onBack,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        return OrderFlowScaffold(
          title: OrderEditConstants.cancelOrderTitle,
          onBack: _onBack,
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: _CancelContent(orderId: widget.orderId, order: order),
            ),
          ),
        );
      },
      loading: () => OrderFlowScaffold(
        title: OrderEditConstants.cancelOrderTitle,
        onBack: _onBack,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => OrderFlowScaffold(
        title: OrderEditConstants.cancelOrderTitle,
        onBack: _onBack,
        child: OrderFlowMessageBody(
          icon: Icons.error_outline_rounded,
          title: 'Unable to load order',
          message: 'Check your connection and try again.',
          action: TextButton(
            onPressed: () => ref.invalidate(orderProvider(widget.orderId)),
            child: Text(OrderEditConstants.retry),
          ),
        ),
      ),
    );
  }
}

class _BackToOrderButton extends StatelessWidget {
  const _BackToOrderButton({required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: () => context.go('/order/$orderId'),
        child: Text(
          OrderEditConstants.backToOrder,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _CancelContent extends ConsumerWidget {
  const _CancelContent({required this.orderId, required this.order});

  final String orderId;
  final OrderView order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentNameAsync = ref.watch(agentFirstNameProvider(orderId));
    final vehicleOptionsSent = ref.watch(vehicleOptionsSentProvider(orderId));
    final cancelState = ref.watch(cancelOrderNotifierProvider(orderId));
    final prefsAsync = ref.watch(_carPrefsForOrderProvider(orderId));
    final agentName = agentNameAsync.valueOrNull ?? 'Your agent';
    final agentId = order.agentId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (vehicleOptionsSent.valueOrNull == true) ...[
          _VehicleOptionsWarning(agentName: agentName),
          const SizedBox(height: 14),
        ],
        if (agentId != null) ...[
          CancelAgentContactSection(
            orderId: orderId,
            agentId: agentId,
            agentName: agentName,
          ),
          const SizedBox(height: 20),
          _SectionDivider(label: OrderEditConstants.cancelDividerLabel),
          const SizedBox(height: 20),
        ] else ...[
          const CancelAgentPendingNote(),
          const SizedBox(height: 20),
        ],
        prefsAsync.when(
          data: (prefs) => _OrderSummaryCard(
            orderRef: order.orderRef,
            make: prefs?['make'] as String? ?? '—',
            model: prefs?['model'] as String? ?? '—',
            yearMin: prefs?['yearMin'] as int? ?? 0,
            yearMax: prefs?['yearMax'] as int? ?? 0,
            agentName: agentName,
            statusLabel: orderStatusLabel(order.status),
          ),
          loading: () => const _SummaryShimmer(),
          error: (_, __) => _OrderSummaryCard(
            orderRef: order.orderRef,
            make: '—',
            model: '—',
            yearMin: 0,
            yearMax: 0,
            agentName: agentName,
            statusLabel: orderStatusLabel(order.status),
          ),
        ),
        const SizedBox(height: 14),
        _NoChargeNote(),
        const SizedBox(height: 24),
        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: cancelState == CancelOrderStatus.cancelling
                ? null
                : () => _confirmCancel(context, ref),
            style: AppButtonStyles.destructive(
              shape: AppButtonStyles.roundedMdShape,
              minimumHeight: 52,
            ),
            child: cancelState == CancelOrderStatus.cancelling
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    OrderEditConstants.yesCancelButton,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 52,
          child: OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.borderSolid),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              OrderEditConstants.noKeepOrderButton,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final ok = await ref
        .read(cancelOrderNotifierProvider(orderId).notifier)
        .cancel();
    if (!context.mounted) return;
    if (ok) {
      context.go('/order/$orderId/cancelled');
    } else {
      showErrorSnackBar(context, OrderEditConstants.couldNotCancelSnackbar);
    }
  }
}

class _VehicleOptionsWarning extends StatelessWidget {
  const _VehicleOptionsWarning({required this.agentName});

  final String agentName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.amberBackground,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: AppColors.warning, width: 3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 18,
            color: AppColors.warning,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              OrderEditConstants.vehicleOptionsWarningCancel
                  .replaceAll('[agentFirstName]', agentName),
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.amberText,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.borderSolid, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.borderSolid, height: 1)),
      ],
    );
  }
}

class _NoChargeNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.successMutedBackground,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: AppColors.success, width: 3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 18,
            color: AppColors.success,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              OrderEditConstants.noChargeNote,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.successMutedForeground,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final _carPrefsForOrderProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, orderId) async {
      final ds = PreferencesFirestoreDataSource(ref.watch(firestoreProvider));
      return ds.getCarPreferences(orderId);
    });

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({
    required this.orderRef,
    required this.make,
    required this.model,
    required this.yearMin,
    required this.yearMax,
    required this.agentName,
    required this.statusLabel,
  });

  final String orderRef;
  final String make;
  final String model;
  final int yearMin;
  final int yearMax;
  final String agentName;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final carLabel = yearMin > 0 && yearMax > 0
        ? '$make $model $yearMin–$yearMax'
        : '$make $model';

    return CardContainer(
      paddingType: CardContainerPaddingType.large,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            OrderEditConstants.cancelThisOrderHeading,
            style: GoogleFonts.dmSans(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            OrderEditConstants.cancelSubtitle,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.borderSolid, height: 1),
          const SizedBox(height: 4),
          _SummaryRow(label: OrderEditConstants.orderLabel, value: orderRef),
          _SummaryRow(label: OrderEditConstants.carLabel, value: carLabel),
          _SummaryRow(label: OrderEditConstants.agentLabel, value: agentName),
          _SummaryRow(label: OrderEditConstants.statusLabel, value: statusLabel),
          _SummaryRow(
            label: OrderEditConstants.amountPaidLabel,
            value: OrderEditConstants.amountPaidZero,
            valueColor: AppColors.success,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.labelMedium.copyWith(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryShimmer extends StatelessWidget {
  const _SummaryShimmer();

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      paddingType: CardContainerPaddingType.large,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
