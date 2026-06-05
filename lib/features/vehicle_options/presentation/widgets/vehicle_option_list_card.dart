import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/buyer_vehicle_response.dart';
import '../../domain/entities/vehicle_option.dart';
import 'listing_source_badge.dart';
import 'vehicle_option_response_badge.dart';

class VehicleOptionListCard extends StatelessWidget {
  const VehicleOptionListCard({
    super.key,
    required this.option,
    required this.onTap,
  });

  final VehicleOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final needsResponse = option.buyerResponse == BuyerVehicleResponse.pending;

    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: needsResponse
                  ? AppColors.warning.withValues(alpha: 0.35)
                  : AppColors.borderSolid,
              width: needsResponse ? 1 : 0.5,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                color: Colors.black.withValues(alpha: 0.06),
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.infoBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.directions_car_outlined,
                  color: AppColors.secondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.displayTitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    if (option.source != null) ...[
                      const SizedBox(height: 6),
                      ListingSourceBadge(source: option.source),
                    ],
                    if (option.agentNote != null &&
                        option.agentNote!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        option.agentNote!.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    VehicleOptionResponseBadge(response: option.buyerResponse),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
