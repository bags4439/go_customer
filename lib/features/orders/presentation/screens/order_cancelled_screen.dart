import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:go_customer/core/error/error_handler.dart';
import 'package:go_customer/core/error/failures.dart';
import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/features/orders/core/constants/order_edit_constants.dart';
import 'package:go_customer/features/orders/presentation/providers/order_providers.dart';
import 'package:go_customer/features/orders/presentation/widgets/hide_cancelled_order_sheet.dart';
import 'package:go_customer/features/orders/presentation/widgets/order_flow_scaffold.dart';

class OrderCancelledScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderCancelledScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderCancelledScreen> createState() =>
      _OrderCancelledScreenState();
}

class _OrderCancelledScreenState extends ConsumerState<OrderCancelledScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _iconController;
  late Animation<double> _iconScale;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _iconScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeOutBack),
    );
    _iconController.forward();
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrderFlowScaffold(
      title: OrderEditConstants.orderCancelledHeading,
      onBack: () => context.go('/home'),
      child: _OrderCancelledContent(
        orderId: widget.orderId,
        iconScale: _iconScale,
      ),
    );
  }
}

class _OrderCancelledContent extends ConsumerWidget {
  final String orderId;
  final Animation<double> iconScale;

  const _OrderCancelledContent({
    required this.orderId,
    required this.iconScale,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderProvider(orderId));
    final orderRef = orderAsync.valueOrNull?.orderRef ?? orderId;
    final hideState = ref.watch(hideCancelledOrderNotifierProvider(orderId));
    final isHiding = hideState == HideCancelledOrderStatus.hiding;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        AnimatedBuilder(
          animation: iconScale,
          builder: (context, child) {
            return Transform.scale(scale: iconScale.value, child: child);
          },
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.dangerMutedBackground,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.cancel_outlined,
              size: 44,
              color: AppColors.danger,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          OrderEditConstants.orderCancelledHeading,
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSolid, width: 0.5),
          ),
          child: Text(
            orderRef,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          OrderEditConstants.noChargesMade,
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.infoBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.infoText.withValues(alpha: 0.12),
            ),
          ),
          child: Text(
            OrderEditConstants.wantToImportDifferent,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.infoText,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: () => context.go('/preferences/new'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              OrderEditConstants.startNewOrder,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: isHiding ? null : () => _onRemove(context, ref),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.borderSolid),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isHiding
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    OrderEditConstants.removeFromOrdersButton,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: TextButton(
            onPressed: () => context.go('/home'),
            child: Text(
              OrderEditConstants.backToHome,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Future<void> _onRemove(BuildContext context, WidgetRef ref) async {
    final confirmed = await showHideCancelledOrderSheet(context);
    if (confirmed != true || !context.mounted) return;

    final ok = await ref
        .read(hideCancelledOrderNotifierProvider(orderId).notifier)
        .hide();
    if (!context.mounted) return;

    if (ok) {
      ref.invalidate(buyerOrdersProvider);
      context.go('/home');
    } else {
      showFailureSnackBar(
        context,
        FirestoreFailure(message: OrderEditConstants.couldNotRemoveSnackbar),
      );
    }
  }
}
