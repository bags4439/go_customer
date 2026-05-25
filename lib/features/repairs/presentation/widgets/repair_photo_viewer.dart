import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'repair_photo_item.dart';

class RepairPhotoViewer extends StatefulWidget {
  const RepairPhotoViewer({
    super.key,
    required this.photos,
    required this.initialIndex,
    required this.jobId,
  });

  final List<RepairPhotoItem> photos;
  final int initialIndex;
  final String jobId;

  @override
  State<RepairPhotoViewer> createState() => _RepairPhotoViewerState();
}

class _RepairPhotoViewerState extends State<RepairPhotoViewer> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.photos.length,
            itemBuilder: (context, index) {
              final item = widget.photos[index];
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: item.url,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    errorWidget: (_, __, ___) => const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: Material(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(24),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
