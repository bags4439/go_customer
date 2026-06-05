import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../core/constants/vehicle_option_constants.dart';
import '../../domain/entities/buyer_vehicle_response.dart';

class VehicleOptionResponseBadge extends StatelessWidget {
  const VehicleOptionResponseBadge({
    super.key,
    required this.response,
  });

  final BuyerVehicleResponse response;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg, icon) = switch (response) {
      BuyerVehicleResponse.pending => (
          VehicleOptionConstants.needsResponseLabel,
          AppColors.amberBackground,
          AppColors.warning,
          Icons.schedule_rounded,
        ),
      BuyerVehicleResponse.interested => (
          'Interested',
          AppColors.success.withValues(alpha: 0.12),
          AppColors.success,
          Icons.favorite_outline_rounded,
        ),
      BuyerVehicleResponse.declined => (
          'Not interested',
          AppColors.surface,
          AppColors.textSecondary,
          Icons.close_rounded,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSolid, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
