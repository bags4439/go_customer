import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';

import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/features/documents/presentation/providers/documents_providers.dart';

class OrderDetailWebDocProgressCard extends ConsumerWidget {
  const OrderDetailWebDocProgressCard({required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(orderDocumentsProvider(orderId));
    final docs = docsAsync.valueOrNull ?? [];
    final agentCount = docs
        .where((d) => d.uploadedByRole == 'agent' && d.docType != 'ghana_id')
        .length;
    const total = 4;

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
          Text('DOCUMENT PROGRESS', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : agentCount / total,
                    backgroundColor: AppColors.borderSolid,
                    color: AppColors.secondary,
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('$agentCount / $total', style: AppTextStyles.labelMedium),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Documents are added automatically as your '
            'order progresses.',
            style: AppTextStyles.caption.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}

class OrderDetailWebDocHelpCard extends StatelessWidget {
  const OrderDetailWebDocHelpCard({required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('NEED HELP?', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 8),
          Text(
            'Your agent can help with any document questions '
            'or missing paperwork.',
            style: AppTextStyles.bodySmall.copyWith(height: 1.5),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.go('/order/$orderId?tab=chat'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondary,
                side: const BorderSide(color: AppColors.secondary, width: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Ask your agent →',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.secondary,
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
