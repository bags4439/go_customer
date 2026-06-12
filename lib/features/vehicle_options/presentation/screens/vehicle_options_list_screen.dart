import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/layout/dashboard_layout.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../../orders/presentation/widgets/order_detail/order_detail_web_navigation.dart';
import '../../../orders/presentation/widgets/order_detail/order_detail_web_panel_chrome.dart';
import '../providers/vehicle_option_providers.dart';
import '../widgets/vehicle_option_list_card.dart';
import '../widgets/vehicle_option_pending_banner.dart';

class VehicleOptionsListScreen extends ConsumerWidget {
  const VehicleOptionsListScreen({
    super.key,
    required this.orderId,
    this.embedInWebPanel = false,
    this.onClosePanel,
  });

  final String orderId;
  final bool embedInWebPanel;
  final VoidCallback? onClosePanel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final optionsAsync = ref.watch(orderVehicleOptionsProvider(orderId));
    final orderRef = ref.watch(orderProvider(orderId)).valueOrNull?.orderRef;
    final pendingCount = ref.watch(pendingVehicleFeedbackCountProvider(orderId));

    final body = optionsAsync.when(
      data: (options) {
        if (options.isEmpty) {
          return _EmptyState(orderId: orderId);
        }
        final sorted = sortVehicleOptionsForList(options);
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
          itemCount: sorted.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final option = sorted[index];
            return VehicleOptionListCard(
              option: option,
              onTap: () => _openDetail(context, ref, option.id),
            );
          },
        );
      },
      loading: () => const _ListShimmer(),
      error: (_, __) => _ErrorState(
        onRetry: () => ref.invalidate(orderVehicleOptionsProvider(orderId)),
      ),
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (pendingCount > 0) ...[
          VehicleOptionPendingBanner(pendingCount: pendingCount),
          const SizedBox(height: 12),
        ],
        Text(
          pendingCount > 0
              ? 'Start with options marked “Needs your response”.'
              : 'Your agent has shared vehicle options for you to review. '
                  'Open each one, view the details, and let them know if you are interested.',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(child: body),
      ],
    );

    if (embedInWebPanel) {
      return OrderDetailWebPanelChrome(
        title: 'Vehicle options',
        orderRef: orderRef,
        onBack: onClosePanel ?? () {},
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Vehicle options',
          style: GoogleFonts.dmSans(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: DashboardPortraitFrame(
        child: Padding(
          padding: ResponsiveLayout.contentPadding(context).copyWith(
            top: 16,
            bottom: 16,
          ),
          child: content,
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, WidgetRef ref, String vehicleOptionId) {
    OrderDetailWebNavigation.openVehicleOptionDetail(
      context,
      ref,
      orderId: orderId,
      vehicleOptionId: vehicleOptionId,
    );
  }
}

class _ListShimmer extends StatelessWidget {
  const _ListShimmer();

  @override
  Widget build(BuildContext context) {
    Widget box(double h) => Shimmer.fromColors(
          baseColor: AppColors.surface,
          highlightColor: Colors.white,
          child: Container(
            height: h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

    return Column(
      children: [
        box(88),
        const SizedBox(height: 10),
        box(88),
        const SizedBox(height: 10),
        box(88),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: AppColors.textTertiary,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'No options yet',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your agent is still searching. New options will appear here when shared.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 32),
          const SizedBox(height: 10),
          Text(
            'Could not load vehicle options',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onRetry,
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
