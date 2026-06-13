import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/layout/app_breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../core/constants/repair_constants.dart';
import 'repair_photo_gallery.dart';
import 'repair_photo_item.dart';

enum RepairPhotoThumbnailSize { compact, standard }

/// Tappable horizontal strip of repair before/after thumbnails.
class RepairPhotoThumbnailStrip extends StatefulWidget {
  const RepairPhotoThumbnailStrip({
    super.key,
    required this.photos,
    required this.galleryId,
    this.size = RepairPhotoThumbnailSize.standard,
    this.maxVisible = 4,
    this.showSectionHint = false,
  });

  final List<RepairPhotoItem> photos;
  final String galleryId;
  final RepairPhotoThumbnailSize size;
  final int maxVisible;
  final bool showSectionHint;

  @override
  State<RepairPhotoThumbnailStrip> createState() =>
      _RepairPhotoThumbnailStripState();
}

class _RepairPhotoThumbnailStripState extends State<RepairPhotoThumbnailStrip> {
  int? _hoverIndex;

  double get _thumbSize => switch (widget.size) {
        RepairPhotoThumbnailSize.compact => 56,
        RepairPhotoThumbnailSize.standard => 80,
      };

  double get _stripHeight => switch (widget.size) {
        RepairPhotoThumbnailSize.compact => 64,
        RepairPhotoThumbnailSize.standard => 100,
      };

  void _open(BuildContext context, int index) {
    RepairPhotoGallery.open(
      context,
      photos: widget.photos,
      initialIndex: index,
      galleryId: widget.galleryId,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photos.isEmpty) return const SizedBox.shrink();

    final visibleCount = widget.maxVisible.clamp(1, widget.photos.length);
    final hasMore = widget.photos.length > visibleCount;
    final displayCount = hasMore ? visibleCount - 1 : visibleCount;
    final moreCount = widget.photos.length - displayCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showSectionHint) ...[
          Row(
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                'Tap to view full size',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          height: _stripHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: displayCount + (hasMore ? 1 : 0),
            separatorBuilder: (_, __) => SizedBox(
              width: widget.size == RepairPhotoThumbnailSize.compact ? 8 : 12,
            ),
            itemBuilder: (context, i) {
              if (hasMore && i == displayCount) {
                return _MoreTile(
                  count: moreCount,
                  size: _thumbSize,
                  onTap: () => _open(context, displayCount),
                );
              }
              return _Thumb(
                item: widget.photos[i],
                size: _thumbSize,
                isHovered: _hoverIndex == i,
                onTap: () => _open(context, i),
                onHover: (v) => setState(() => _hoverIndex = v ? i : null),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.item,
    required this.size,
    required this.onTap,
    required this.onHover,
    this.isHovered = false,
  });

  final RepairPhotoItem item;
  final double size;
  final VoidCallback onTap;
  final ValueChanged<bool> onHover;
  final bool isHovered;

  @override
  Widget build(BuildContext context) {
    final isWeb = AppBreakpoints.useWebShell(context);

    return MouseRegion(
      onEnter: isWeb ? (_) => onHover(true) : null,
      onExit: isWeb ? (_) => onHover(false) : null,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: isHovered ? 1.04 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: isHovered
                    ? AppColors.secondary.withValues(alpha: 0.6)
                    : AppColors.borderSolid,
                width: isHovered ? 1.5 : 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isHovered ? 0.1 : 0.05),
                  blurRadius: isHovered ? 12 : 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                AppTheme.radiusMd - (isHovered ? 0 : 0),
              ),
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
                    errorWidget: (_, __, ___) => ColoredBox(
                      color: AppColors.surface,
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.textTertiary,
                        size: size * 0.35,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 5,
                    bottom: 5,
                    child: _LabelChip(isBefore: item.isBefore),
                  ),
                  if (isHovered)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.open_in_full_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.count,
    required this.size,
    required this.onTap,
  });

  final int count;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppColors.borderSolid),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 18,
                color: AppColors.secondary,
              ),
              const SizedBox(height: 4),
              Text(
                '+$count',
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabelChip extends StatelessWidget {
  const _LabelChip({required this.isBefore});

  final bool isBefore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isBefore
            ? Colors.white.withValues(alpha: 0.92)
            : AppColors.successMutedBackground,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        isBefore ? RepairConstants.beforeLabel : RepairConstants.afterLabel,
        style: AppTextStyles.caption.copyWith(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: isBefore ? AppColors.textSecondary : AppColors.successMutedForeground,
        ),
      ),
    );
  }
}
