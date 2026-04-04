import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/photo_viewer.dart';
import '../providers/vehicle_detail_providers.dart';

class AgentVehicleAvatar extends StatelessWidget {
  const AgentVehicleAvatar({
    super.key,
    required this.agent,
    required this.radius,
    this.heroTag,
  });

  final AgentForVehicleView agent;
  final double radius;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final photoUrl = agent.photoUrl;
    final d = radius * 2;
    final tag = heroTag ?? 'agent_vehicle_avatar_${agent.agentId}';

    if (photoUrl != null && photoUrl.isNotEmpty) {
      final image = Hero(
        tag: tag,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: photoUrl,
            width: d,
            height: d,
            fit: BoxFit.cover,
            placeholder: (_, __) => Shimmer.fromColors(
              baseColor: AppColors.surface,
              highlightColor: Colors.white,
              child: Container(
                width: d,
                height: d,
                color: AppColors.surface,
              ),
            ),
            errorWidget: (_, __, ___) => GestureDetector(
              onTap: () {},
              behavior: HitTestBehavior.opaque,
              child: _initialsCircle(d),
            ),
          ),
        ),
      );

      return GestureDetector(
        onTap: () => PhotoViewer.show(
          context,
          photoUrl: photoUrl,
          heroTag: tag,
          label: agent.fullName,
        ),
        child: image,
      );
    }

    return _initialsCircle(d);
  }

  Widget _initialsCircle(double d) {
    return Container(
      width: d,
      height: d,
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        agent.initials,
        style: GoogleFonts.dmSans(
          fontSize: d * 0.35,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
