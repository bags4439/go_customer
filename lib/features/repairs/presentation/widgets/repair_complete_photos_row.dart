import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../core/constants/repair_constants.dart';
import 'repair_photo_gallery.dart';
import 'repair_photo_item.dart';
import 'repair_photo_thumbnail_strip.dart';

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
          border: Border.all(color: AppColors.borderSolid, width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 32,
              color: AppColors.textTertiary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                RepairConstants.state4PhotosPlaceholder,
                style: AppTextStyles.cardLabel.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RepairPhotoThumbnailStrip(
      photos: photos,
      galleryId: jobId,
      size: RepairPhotoThumbnailSize.standard,
      maxVisible: 6,
      showSectionHint: true,
    );
  }
}

/// Convenience builder from raw URL lists (timeline, in-progress, etc.).
class RepairJobPhotoStrip extends StatelessWidget {
  const RepairJobPhotoStrip({
    super.key,
    required this.beforeUrls,
    required this.afterUrls,
    required this.galleryId,
    this.size = RepairPhotoThumbnailSize.standard,
    this.maxVisible = 4,
    this.showSectionHint = false,
  });

  final List<String> beforeUrls;
  final List<String> afterUrls;
  final String galleryId;
  final RepairPhotoThumbnailSize size;
  final int maxVisible;
  final bool showSectionHint;

  @override
  Widget build(BuildContext context) {
    final photos = RepairPhotoGallery.fromUrls(
      beforeUrls: beforeUrls,
      afterUrls: afterUrls,
    );
    if (photos.isEmpty) return const SizedBox.shrink();

    return RepairPhotoThumbnailStrip(
      photos: photos,
      galleryId: galleryId,
      size: size,
      maxVisible: maxVisible,
      showSectionHint: showSectionHint,
    );
  }
}
