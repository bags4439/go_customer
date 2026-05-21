import 'package:flutter/material.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/features/orders/domain/entities/order_view.dart';
import 'order_detail_car_card.dart';

class OrderDetailWebOrderSummaryCard extends StatelessWidget {
  const OrderDetailWebOrderSummaryCard({required this.order});

  final OrderView? order;

  static String? _yearPreferenceLabel(OrderView o) {
    if (o.yearMin != null && o.yearMax != null) {
      if (o.isSingleYear || o.yearMin == o.yearMax) {
        return '${o.yearMin}';
      }
      return '${o.yearMin}–${o.yearMax}';
    }
    if (o.yearMin != null) return '${o.yearMin}';
    if (o.yearMax != null) return '${o.yearMax}';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (order == null) return const SizedBox.shrink();
    final carName = '${order!.make ?? ''} ${order!.model ?? ''}'.trim();
    final yearLabel = _yearPreferenceLabel(order!);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderSolid, width: .5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ORDER SUMMARY', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 10),
          OrderDetailWebRightPanelRow(
            label: 'Vehicle',
            value: carName.isNotEmpty ? carName : '—',
          ),
          OrderDetailWebRightPanelRow(
            label: 'Source',
            value: orderDetailOriginLabel(order!.purchaseOrigin),
          ),
          OrderDetailWebRightPanelRow(
            label: 'Stage',
            value: '${order!.stageNumber} of 9',
            valueBadge: true,
          ),
          if (yearLabel != null)
            OrderDetailWebRightPanelRow(label: 'Year', value: yearLabel),
        ],
      ),
    );
  }
}

class OrderDetailWebRightPanelRow extends StatelessWidget {
  const OrderDetailWebRightPanelRow({
    required this.label,
    required this.value,
    this.valueBadge = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool valueBadge;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final Widget valueWidget;
    if (valueBadge) {
      valueWidget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.infoBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          value,
          style: AppTextStyles.cardValue.copyWith(color: AppColors.infoText),
        ),
      );
    } else {
      valueWidget = Text(
        value,
        style: valueColor != null
            ? AppTextStyles.cardValue.copyWith(color: valueColor)
            : AppTextStyles.cardValue,
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.cardLabel),
          valueWidget,
        ],
      ),
    );
  }
}

class OrderDetailWebOrderContextCard extends StatelessWidget {
  const OrderDetailWebOrderContextCard({required this.order});

  final OrderView? order;

  @override
  Widget build(BuildContext context) {
    if (order == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderSolid, width: .5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ORDER CONTEXT', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 10),
          OrderDetailWebRightPanelRow(
            label: 'Stage',
            value: '${order!.stageNumber} of 9',
            valueBadge: true,
          ),
          OrderDetailWebRightPanelRow(
            label: 'Payment',
            value: order!.needsPayment ? 'Due' : 'Up to date',
            valueColor: order!.needsPayment
                ? AppColors.danger
                : AppColors.successMutedForeground,
          ),
          OrderDetailWebRightPanelRow(
            label: 'Vehicle',
            value: '${order!.make ?? ''} ${order!.model ?? ''}'.trim(),
          ),
        ],
      ),
    );
  }
}

/// Right panel step detail (web overview).
