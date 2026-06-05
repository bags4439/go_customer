import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/vehicle_option_providers.dart';

class VehicleOptionAgentNote extends ConsumerWidget {
  const VehicleOptionAgentNote({
    super.key,
    required this.vehicleOptionId,
    required this.note,
  });

  final String vehicleOptionId;
  final String note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentAsync = ref.watch(agentForVehicleProvider(vehicleOptionId));
    final title = agentAsync.when(
      data: (agent) {
        final first = agent?.firstName;
        if (first != null && first.isNotEmpty) {
          return "Note from $first";
        }
        return 'Note from your agent';
      },
      loading: () => 'Note from your agent',
      error: (_, __) => 'Note from your agent',
    );

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF9F8F5),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
        border: Border(
          left: BorderSide(color: AppColors.secondary, width: 3),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.secondary,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            note,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
