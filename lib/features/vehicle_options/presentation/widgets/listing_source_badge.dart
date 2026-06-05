import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/listing_source.dart';

class ListingSourceBadge extends StatelessWidget {
  const ListingSourceBadge({
    super.key,
    required this.source,
  });

  final ListingSource? source;

  @override
  Widget build(BuildContext context) {
    if (source == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSolid, width: 0.5),
      ),
      child: Text(
        source!.displayLabel,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
