import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

/// Full-screen agent photo with pinch-zoom.
class OrderDetailAgentPhotoViewer extends StatelessWidget {
  const OrderDetailAgentPhotoViewer({
    super.key,
    required this.photoUrl,
    required this.agentName,
  });

  final String photoUrl;
  final String agentName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: 'agent_photo_$photoUrl',
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 5.0,
                child: CachedNetworkImage(
                  imageUrl: photoUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  errorWidget: (_, __, ___) => const ColoredBox(
                    color: Color(0xFF1A1A18),
                    child: Icon(
                      Icons.person_outline,
                      size: 64,
                      color: Colors.white24,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                8,
                MediaQuery.paddingOf(context).top + 8,
                8,
                16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      agentName,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
