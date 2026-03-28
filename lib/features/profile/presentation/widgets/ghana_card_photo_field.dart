import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

class GhanaCardPhotoField extends StatelessWidget {
  const GhanaCardPhotoField({
    super.key,
    required this.localPath,
    required this.existingUrl,
    required this.isUploading,
    required this.onPick,
    required this.onClear,
  });

  final String? localPath;
  final String? existingUrl;
  final bool isUploading;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasLocal = localPath != null;
    final hasExisting = existingUrl != null && existingUrl!.isNotEmpty;
    final hasPhoto = hasLocal || hasExisting;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: isUploading ? null : onPick,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 130,
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.borderSolid),
              borderRadius: BorderRadius.circular(12),
            ),
            child: hasPhoto
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (hasLocal)
                          Image.file(File(localPath!), fit: BoxFit.cover)
                        else
                          CachedNetworkImage(
                            imageUrl: existingUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => ColoredBox(
                              color: AppColors.surface,
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => const Icon(
                              Icons.image_not_supported_outlined,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            color: Colors.black.withValues(alpha: 0.4),
                            child: Text(
                              'Tap to change',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        if (isUploading)
                          const Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: LinearProgressIndicator(
                              minHeight: 3,
                              color: AppColors.secondary,
                            ),
                          ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.camera_alt_outlined,
                        size: 32,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to upload photo',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Camera or gallery',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (hasLocal && !isUploading)
          Positioned(
            top: -8,
            right: -8,
            child: GestureDetector(
              onTap: onClear,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
