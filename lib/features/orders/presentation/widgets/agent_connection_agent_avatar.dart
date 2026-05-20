import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/photo_viewer.dart';
import '../../domain/entities/agent_detail_view.dart';

class AgentConnectionAgentAvatar extends StatelessWidget {
  const AgentConnectionAgentAvatar({
    super.key,
    required this.agent,
    required this.radius,
    this.heroTag,
  });

  final AgentDetailView agent;
  final double radius;

  /// When provided and a photo exists, tapping opens the full-screen photo
  /// viewer with Hero animation. Use a unique string per usage site, e.g.
  /// `'agent_avatar_${agent.agentId}_connection'`.
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final photoUrl = agent.photoUrl;
    final d = radius * 2;
    final tag = heroTag ?? 'agent_avatar_${agent.agentId}';

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
              child: Container(width: d, height: d, color: AppColors.surface),
            ),
            errorWidget: (_, __, ___) => GestureDetector(
              onTap: () {},
              behavior: HitTestBehavior.opaque,
              child: _InitialsCircle(radius: radius, agent: agent),
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

    return _InitialsCircle(radius: radius, agent: agent);
  }
}

class _InitialsCircle extends StatelessWidget {
  const _InitialsCircle({required this.radius, required this.agent});

  final double radius;
  final AgentDetailView agent;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.secondary,
      child: Text(
        agent.initials,
        style: GoogleFonts.dmSans(
          fontSize: radius * 0.7,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
