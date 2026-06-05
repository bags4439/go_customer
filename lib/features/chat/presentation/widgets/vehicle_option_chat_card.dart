import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../orders/presentation/widgets/order_detail/order_detail_web_navigation.dart';
import '../../../vehicle_options/domain/entities/vehicle_option.dart';
import '../../../vehicle_options/presentation/providers/vehicle_option_providers.dart';
import '../../../vehicle_options/presentation/widgets/listing_source_badge.dart';
import '../../../vehicle_options/presentation/widgets/vehicle_option_response_badge.dart';

/// In-chat compact card linking to the full vehicle option detail screen.
class VehicleOptionChatCard extends ConsumerWidget {
  const VehicleOptionChatCard({
    super.key,
    required this.orderId,
    required this.vehicleOptionId,
  });

  final String orderId;
  final String vehicleOptionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final optionAsync = ref.watch(vehicleOptionStreamProvider(vehicleOptionId));

    return optionAsync.when(
      data: (option) {
        if (option == null || !option.isVisibleToBuyer) {
          return const SizedBox.shrink();
        }
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: _CompactCard(
              orderId: orderId,
              option: option,
              onOpen: () => OrderDetailWebNavigation.openVehicleOptionDetail(
                context,
                ref,
                orderId: orderId,
                vehicleOptionId: vehicleOptionId,
              ),
            ),
          ),
        );
      },
      loading: () => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: const _CardShimmer(),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _CompactCard extends StatelessWidget {
  const _CompactCard({
    required this.orderId,
    required this.option,
    required this.onOpen,
  });

  final String orderId;
  final VehicleOption option;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSolid, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.infoBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.directions_car_outlined,
                        size: 18,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.displayTitle,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (option.source != null) ...[
                            const SizedBox(height: 4),
                            ListingSourceBadge(source: option.source),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (option.agentNote != null &&
                    option.agentNote!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    option.agentNote!.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    VehicleOptionResponseBadge(response: option.buyerResponse),
                    const Spacer(),
                    Text(
                      'View details →',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardShimmer extends StatelessWidget {
  const _CardShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: Colors.white,
      child: Container(
        height: 110,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
