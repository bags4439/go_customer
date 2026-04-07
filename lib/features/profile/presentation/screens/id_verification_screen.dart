import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/styled_snackbar.dart';
import '../../core/constants/profile_constants.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../providers/profile_providers.dart';
import '../widgets/ghana_card_number_field.dart';
import '../widgets/ghana_card_photo_field.dart';

class IdVerificationScreen extends ConsumerStatefulWidget {
  const IdVerificationScreen({super.key});

  @override
  ConsumerState<IdVerificationScreen> createState() =>
      _IdVerificationScreenState();
}

class _IdVerificationScreenState extends ConsumerState<IdVerificationScreen> {
  late final TextEditingController _cardNumberController;
  String? _lastInitUserId;
  String? _initScheduledForUserId;

  @override
  void initState() {
    super.initState();
    _cardNumberController = TextEditingController();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    super.dispose();
  }

  /// Must not call [GhanaCardNotifier.init] synchronously from [build] —
  /// defer to the next frame so Riverpod is not modified during layout.
  void _scheduleInitIfNeeded(AppUser user) {
    if (_lastInitUserId == user.id) return;
    if (_initScheduledForUserId == user.id) return;
    _initScheduledForUserId = user.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initScheduledForUserId = null;
      if (!mounted) return;
      if (_lastInitUserId == user.id) return;
      _lastInitUserId = user.id;
      ref.read(ghanaCardProvider.notifier).init(user);
      _cardNumberController.text = user.ghanaCardNumber ?? '';
    });
  }

  bool _canSave(AppUser user, GhanaCardState s) {
    if (s.status == GhanaCardSaveStatus.saving) return false;
    final orig = (user.ghanaCardNumber ?? '').trim();
    final changed = s.cardNumber.trim() != orig || s.photoPath != null;
    final hasPayload = s.cardNumber.trim().isNotEmpty || s.photoPath != null;
    return changed && hasPayload;
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderSolid,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text('Take a photo', style: GoogleFonts.dmSans()),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text('Choose from gallery', style: GoogleFonts.dmSans()),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1400,
    );
    if (file == null || !mounted) return;
    ref.read(ghanaCardProvider.notifier).setPhoto(file.path);
  }

  Future<void> _save() async {
    await ref.read(ghanaCardProvider.notifier).save();
    if (!mounted) return;
    final state = ref.read(ghanaCardProvider);
    if (state.status == GhanaCardSaveStatus.error) {
      showErrorSnackBar(
        context,
        state.errorMessage ?? 'Could not save. Try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardState = ref.watch(ghanaCardProvider);
    final profileAsync = ref.watch(currentUserProfileProvider);

    ref.listen<GhanaCardState>(ghanaCardProvider, (prev, next) {
      if (next.status == GhanaCardSaveStatus.success &&
          prev?.status != GhanaCardSaveStatus.success) {
        if (!context.mounted) return;
        final u = ref.read(currentUserProfileProvider).valueOrNull;
        final label = u?.idDocumentLabel ?? 'Document';
        showSuccessSnackBar(
          context,
          '$label saved.',
        );
        context.pop();
      }
    });

    final isSaving = cardState.status == GhanaCardSaveStatus.saving;
    final appBarDocLabel =
        profileAsync.valueOrNull?.idDocumentLabel ??
            ProfileConstants.idVerificationTitle;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          appBarDocLabel,
          style: GoogleFonts.dmSans(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.borderSolid),
        ),
      ),
      body: profileAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Please sign in'));
          }
          final isGhanaian = user.isGhanaian;
          final docLabel = user.idDocumentLabel;
          final numberLabel = isGhanaian
              ? 'CARD NUMBER'
              : 'PASSPORT NUMBER';
          final numberHint =
              isGhanaian ? 'GHA-XXXXXXXXX-X' : 'A12345678';
          final numberFormatHint = isGhanaian
              ? 'Format: GHA-XXXXXXXXX-X'
              : 'Enter your passport number';
          final photoLabel =
              isGhanaian ? 'CARD PHOTO' : 'PASSPORT PHOTO';
          final hasDoc = user.hasIdDocument;
          final headingText = hasDoc
              ? 'Update your $docLabel'
              : 'Add your $docLabel';
          final buttonText = hasDoc
              ? 'Update $docLabel'
              : 'Save $docLabel';

          _scheduleInitIfNeeded(user);
          final canSave = _canSave(user, cardState);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  headingText,
                  style: GoogleFonts.dmSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your ${docLabel.toLowerCase()} details are kept private '
                  'and used only to verify your identity.',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  numberLabel,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                GhanaCardNumberField(
                  controller: _cardNumberController,
                  onChanged: (v) =>
                      ref.read(ghanaCardProvider.notifier).updateCardNumber(v),
                  hintText: numberHint,
                ),
                const SizedBox(height: 6),
                Text(
                  numberFormatHint,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  photoLabel,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                GhanaCardPhotoField(
                  localPath: cardState.photoPath,
                  existingUrl: cardState.existingPhotoUrl,
                  isUploading: isSaving,
                  onPick: _pickPhoto,
                  onClear: () =>
                      ref.read(ghanaCardProvider.notifier).clearPhoto(),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (canSave && !isSaving) ? _save : null,
                    style:
                        ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: AppColors.background,
                          disabledBackgroundColor: AppColors.borderSolid,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ).copyWith(
                          elevation: WidgetStateProperty.resolveWith((s) {
                            if (s.contains(WidgetState.disabled)) return 0;
                            if (s.contains(WidgetState.pressed)) return 0;
                            return canSave ? 3.0 : 0.0;
                          }),
                          shadowColor: WidgetStateProperty.all(
                            AppColors.secondary.withValues(alpha: 0.3),
                          ),
                        ),
                    child: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            buttonText,
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.secondary),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ProfileConstants.errorLoadProfile,
                style: GoogleFonts.dmSans(),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => ref.invalidate(currentUserProfileProvider),
                child: Text(
                  ProfileConstants.retry,
                  style: GoogleFonts.dmSans(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
