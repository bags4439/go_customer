import 'package:flutter/material.dart';

import '../../core/constants/repair_constants.dart';
import 'repair_photo_item.dart';
import 'repair_photo_viewer.dart';

/// Builds photo lists and opens the shared repair gallery viewer.
abstract final class RepairPhotoGallery {
  RepairPhotoGallery._();

  static List<RepairPhotoItem> fromUrls({
    required List<String> beforeUrls,
    required List<String> afterUrls,
  }) {
    return [
      ...beforeUrls.map((u) => RepairPhotoItem(u, true)),
      ...afterUrls.map((u) => RepairPhotoItem(u, false)),
    ];
  }

  static List<RepairPhotoItem> beforeOnly(List<String> urls) =>
      urls.map((u) => RepairPhotoItem(u, true)).toList();

  static List<RepairPhotoItem> afterOnly(List<String> urls) =>
      urls.map((u) => RepairPhotoItem(u, false)).toList();

  static String labelFor(RepairPhotoItem item) =>
      item.isBefore ? RepairConstants.beforeLabel : RepairConstants.afterLabel;

  static Future<void> open(
    BuildContext context, {
    required List<RepairPhotoItem> photos,
    required int initialIndex,
    required String galleryId,
  }) {
    if (photos.isEmpty) return Future.value();
    final index = initialIndex.clamp(0, photos.length - 1);
    return RepairPhotoViewer.show(
      context,
      photos: photos,
      initialIndex: index,
      galleryId: galleryId,
    );
  }
}
