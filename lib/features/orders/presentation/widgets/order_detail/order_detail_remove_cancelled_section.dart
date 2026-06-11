import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:go_customer/core/error/error_handler.dart';
import 'package:go_customer/core/error/failures.dart';
import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/core/widgets/card_container.dart';
import 'package:go_customer/features/orders/core/constants/order_edit_constants.dart';
import 'package:go_customer/features/orders/presentation/providers/order_providers.dart';
import 'package:go_customer/features/orders/presentation/widgets/hide_cancelled_order_sheet.dart';

/// Remove a cancelled order from buyer and agent lists.
class OrderDetailRemoveCancelledSection extends ConsumerWidget {
  final String orderId;

  const OrderDetailRemoveCancelledSection({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hideState = ref.watch(hideCancelledOrderNotifierProvider(orderId));
    final isHiding = hideState == HideCancelledOrderStatus.hiding;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CardContainer(
          paddingType: CardContainerPaddingType.large,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.dangerMutedBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.cancel_outlined,
                      size: 18,
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      OrderEditConstants.cancelledOrderBannerTitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                OrderEditConstants.cancelledOrderBannerBody,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 52,
          child: OutlinedButton(
            onPressed: isHiding
                ? null
                : () => _onRemovePressed(context, ref),
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
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _onRemovePressed(BuildContext context, WidgetRef ref) async {
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
