import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../core/constants/repair_constants.dart';
import 'repair_photo_item.dart';
import 'repair_photo_viewer.dart';

class RepairCompletePhotosRow extends StatelessWidget {
  const RepairCompletePhotosRow({
    super.key,
    required this.photos,
    required this.jobId,
  });

  final List<RepairPhotoItem> photos;
  final String jobId;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 32,
              color: Colors.grey.shade500,
            ),
            const SizedBox(width: 12),
            Text(
              RepairConstants.state4PhotosPlaceholder,
              style: AppTextStyles.cardLabel.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      );
    }
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        itemBuilder: (context, i) {
          final item = photos[i];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _openPhotoViewer(context, photos, i),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: item.url,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Shimmer.fromColors(
                          baseColor: AppColors.surface,
                          highlightColor: Colors.white,
                          child: Container(color: AppColors.surface),
                        ),
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.danger,
                        ),
                      ),
                      Positioned(
                        left: 4,
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: item.isBefore
                                ? AppColors.surface
                                : const Color(0xFFEAF3DE),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.isBefore
                                ? RepairConstants.beforeLabel
                                : RepairConstants.afterLabel,
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10,
                              color: item.isBefore
                                  ? const Color(0xFF666666)
                                  : const Color(0xFF27500A),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openPhotoViewer(
    BuildContext context,
    List<RepairPhotoItem> photos,
    int initialIndex,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (ctx) => RepairPhotoViewer(
          photos: photos,
          initialIndex: initialIndex,
          jobId: jobId,
        ),
      ),
    );
  }
}
