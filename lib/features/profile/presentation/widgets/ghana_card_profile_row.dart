import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/app_user.dart';

/// Tappable row linking to identity document add/update from profile.
class GhanaCardProfileRow extends StatelessWidget {
  const GhanaCardProfileRow({super.key, required this.user});

  final AppUser user;

  String get _label {
    if (user.idDocumentType == 'passport') {
      return 'Passport';
    }
    if (user.country == 'GH' || user.idDocumentType == 'ghana_card') {
      return 'Ghana Card';
    }
    return user.isGhanaian ? 'Ghana Card' : 'Passport';
  }

  String get _valueLabel {
    final n = user.ghanaCardNumber?.trim() ?? '';
    if (n.length >= 4) {
      return '···${n.substring(n.length - 4)}';
    }
    if (n.isNotEmpty) return n;
    if (user.hasIdDocument) return 'Photo on file';
    return 'Not added';
  }

  bool get _hasValue => user.hasIdDocument;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.pushNamed(RouteConstants.idVerification),
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _label,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _valueLabel,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: _hasValue
                            ? AppColors.textSecondary
                            : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 24,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
