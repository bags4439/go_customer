import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/styled_snackbar.dart';
import '../../core/constants/profile_constants.dart';
import '../../../documents/presentation/widgets/dashed_border_painter.dart';
import '../providers/profile_providers.dart';

const Color _kPrimary = Color(0xFF378ADD);
const Color _kSuccess = Color(0xFF1D9E75);
const Color _kDarkGreen = Color(0xFF27500A);
const Color _kGreenText = Color(0xFF3B6D11);
const Color _kWarning = Color(0xFFBA7517);
const Color _kDanger = Color(0xFFE24B4A);
const Color _kSurface = Color(0xFFF5F4F0);
const Color _kBorder = Color(0xFFE0DFD8);
const Color _kTextTertiary = Color(0xFFAAAAAA);
const Color _kAmberBg = Color(0xFFFAEEDA);
const Color _kPlaceholderBg = Color(0xFFF9F8F5);
const Color _kDashedBorder = Color(0xFFD0CFC8);
const int _kMaxFileBytes = 5 * 1024 * 1024;

class IdVerificationScreen extends ConsumerStatefulWidget {
  const IdVerificationScreen({super.key});

  @override
  ConsumerState<IdVerificationScreen> createState() =>
      _IdVerificationScreenState();
}

class _IdVerificationScreenState extends ConsumerState<IdVerificationScreen> {
  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final uploadState = ref.watch(idVerificationUploadProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          ProfileConstants.idVerificationTitle,
          style: GoogleFonts.dmSans(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: profileAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Please sign in'));
          }
          final underReview =
              user.ghanaidUrl != null && user.ghanaidUrl!.isNotEmpty && !user.ghanaidVerified;
          final showUpload = !user.ghanaidVerified &&
              (user.ghanaidUrl == null ||
                  user.ghanaidUrl!.isEmpty ||
                  uploadState.status == IdVerificationUploadStatus.error);

          if (uploadState.status == IdVerificationUploadStatus.success) {
            return _SuccessView(onBack: () => context.pop());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StatusBanner(
                  hasDocument: user.ghanaidUrl != null && user.ghanaidUrl!.isNotEmpty,
                  underReview: underReview,
                ),
                if (showUpload) ...[
                  const SizedBox(height: 20),
                  _UploadArea(
                    uploadState: uploadState,
                    onTap: _pickFile,
                    onChangeFile: () => ref
                        .read(idVerificationUploadProvider.notifier)
                        .clearSelection(),
                    onUpload: () => ref
                        .read(idVerificationUploadProvider.notifier)
                        .startUpload(),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ProfileConstants.errorLoadProfile,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(currentUserProfileProvider),
                child: const Text(ProfileConstants.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    final path = file.path;
    if (path == null) return;
    final size = file.size ?? 0;
    if (size > _kMaxFileBytes) {
      if (mounted) {
        showErrorSnackBar(context, ProfileConstants.errorFileTooLarge);
      }
      return;
    }
    final ext = path.split('.').last.toLowerCase();
    final isPdf = ext == 'pdf';
    ref.read(idVerificationUploadProvider.notifier).setSelected(
          path: path,
          name: file.name,
          isPdf: isPdf,
        );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.hasDocument,
    required this.underReview,
  });

  final bool hasDocument;
  final bool underReview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: underReview ? _kAmberBg : _kSurface,
        borderRadius: BorderRadius.circular(8),
        border: underReview
            ? const Border(left: BorderSide(color: _kWarning, width: 3))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            underReview ? Icons.info_outline : Icons.upload_file_outlined,
            size: 24,
            color: underReview ? _kWarning : _kTextTertiary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  underReview
                      ? ProfileConstants.idUnderReviewMessage
                      : ProfileConstants.idUploadTitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadArea extends StatelessWidget {
  const _UploadArea({
    required this.uploadState,
    required this.onTap,
    required this.onChangeFile,
    required this.onUpload,
  });

  final IdVerificationUploadState uploadState;
  final VoidCallback onTap;
  final VoidCallback onChangeFile;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final isSelected = uploadState.status == IdVerificationUploadStatus.selected;
    final isUploading =
        uploadState.status == IdVerificationUploadStatus.uploading;
    final isError = uploadState.status == IdVerificationUploadStatus.error;

    if (isUploading) {
      return Container(
        height: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _kPlaceholderBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kDashedBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LinearProgressIndicator(
              value: uploadState.uploadProgress,
              backgroundColor: _kBorder,
              valueColor: const AlwaysStoppedAnimation<Color>(_kPrimary),
            ),
            const SizedBox(height: 12),
            Text(
              'Uploading... ${(uploadState.uploadProgress * 100).toInt()}%',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    if (isSelected) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 120,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kPlaceholderBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isError ? _kDanger : _kBorder),
            ),
            child: Row(
              children: [
                Icon(
                  uploadState.isPdf ? Icons.picture_as_pdf : Icons.image_outlined,
                  size: 48,
                  color: _kPrimary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        uploadState.selectedFileName ?? 'File',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isError) ...[
            const SizedBox(height: 8),
            Text(
              uploadState.errorMessage ?? ProfileConstants.errorUploadFailed,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: _kDanger,
              ),
            ),
          ],
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onChangeFile,
            child: Text(
              ProfileConstants.changeFile,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: _kPrimary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: onUpload,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                ProfileConstants.uploadDocument,
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: _kDashedBorder,
          dashLength: 4,
          gapLength: 3,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          height: 160,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: _kPlaceholderBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_upload_outlined,
                  size: 40,
                  color: _kPrimary,
                ),
                const SizedBox(height: 12),
                Text(
                  ProfileConstants.tapToUpload,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ProfileConstants.ghanaCardOrPassport,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ProfileConstants.fileTypesHint,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: _kTextTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: _kSuccess,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            ProfileConstants.documentUploadedTitle,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _kDarkGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ProfileConstants.documentUploadedSubtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: _kGreenText,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onBack,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                ProfileConstants.backToProfile,
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
