import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

import '../../core/constants/order_edit_constants.dart';
import '../providers/order_providers.dart';

const _kBorderColor = 0xFFE0DFD8;
const _kSurface = 0xFFF5F4F0;
const _kDanger = 0xFFE24B4A;
const _kPrimary = 0xFF378ADD;
const _kTextSecondary = 0xFF666666;

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
      duration: const Duration(milliseconds: 400),
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
    return Scaffold(
      body: SafeArea(
        child: _OrderCancelledContent(
          orderId: widget.orderId,
          iconScale: _iconScale,
        ),
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

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: iconScale,
            builder: (context, child) {
              return Transform.scale(scale: iconScale.value, child: child);
            },
            child: const Icon(
              Icons.cancel_outlined,
              size: 64,
              color: Color(_kDanger),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            OrderEditConstants.orderCancelledHeading,
            style: AppTextStyles.amountMedium,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(_kSurface),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(orderRef, style: AppTextStyles.labelMedium),
          ),
          const SizedBox(height: 8),
          Text(
            OrderEditConstants.noChargesMade,
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(_kTextSecondary),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(height: 0.5, color: const Color(_kBorderColor)),
          const SizedBox(height: 20),
          Text(
            OrderEditConstants.wantToImportDifferent,
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(_kTextSecondary),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => context.go('/preferences/new'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(_kPrimary),
                foregroundColor: Colors.white,
              ),
              child: Text(
                OrderEditConstants.startNewOrder,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => context.go('/home'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(_kBorderColor)),
                foregroundColor: const Color(_kTextSecondary),
              ),
              child: Text(
                OrderEditConstants.backToHome,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
