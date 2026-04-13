import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../delivery/presentation/providers/delivery_providers.dart';
import '../../../orders/data/models/buyer_review_model.dart';
import '../providers/order_providers.dart';

class BuyerReviewScreen extends ConsumerStatefulWidget {
  const BuyerReviewScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<BuyerReviewScreen> createState() => _BuyerReviewScreenState();
}

class _BuyerReviewScreenState extends ConsumerState<BuyerReviewScreen> {
  double _overallRating = 0;
  double _agentRating = 0;
  double _communicationRating = 0;
  double _speedRating = 0;
  final _commentCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _overallRating > 0 &&
      _agentRating > 0 &&
      _communicationRating > 0 &&
      _speedRating > 0;

  void _snackError(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.dmSans(color: Colors.white, fontSize: 14),
        ),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderProvider(widget.orderId));
    final order = orderAsync.valueOrNull;
    final userId = ref.watch(authStateProvider).value;
    final reviewAsync = userId != null
        ? ref.watch(
            buyerReviewProvider((
              orderId: widget.orderId,
              buyerId: userId,
            )),
          )
        : null;
    final existingReview = reviewAsync?.valueOrNull;

    if (existingReview != null) {
      return _SubmittedScreen(
        orderId: widget.orderId,
        review: existingReview,
      );
    }

    return PopScope(
      canPop: !_isSubmitting,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
            ),
            color: AppColors.textPrimary,
            onPressed: _isSubmitting
                ? null
                : () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              minimumSize: const Size(48, 48),
            ),
          ),
          title: Text(
            'Rate your experience',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0.5),
            child: Container(
              height: 0.5,
              color: AppColors.borderSolid,
            ),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveLayout.contentMaxWidth(context),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                20 + MediaQuery.paddingOf(context).bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.successMutedBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.local_shipping_rounded,
                          size: 48,
                          color: AppColors.success,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Your vehicle has been delivered!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A4731),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Please rate your experience to complete your order.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: const Color(0xFF2D6A4F),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  _RatingRow(
                    label: 'Overall experience',
                    description: 'How satisfied are you overall?',
                    rating: _overallRating,
                    onRatingChanged: (r) => setState(() => _overallRating = r),
                  ),
                  const SizedBox(height: 20),
                  _RatingRow(
                    label: 'Agent performance',
                    description: 'How well did your agent serve you?',
                    rating: _agentRating,
                    onRatingChanged: (r) => setState(() => _agentRating = r),
                  ),
                  const SizedBox(height: 20),
                  _RatingRow(
                    label: 'Communication',
                    description: 'Was your agent responsive and clear?',
                    rating: _communicationRating,
                    onRatingChanged: (r) =>
                        setState(() => _communicationRating = r),
                  ),
                  const SizedBox(height: 20),
                  _RatingRow(
                    label: 'Speed of service',
                    description: 'How timely was the overall process?',
                    rating: _speedRating,
                    onRatingChanged: (r) => setState(() => _speedRating = r),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'ADDITIONAL COMMENTS (OPTIONAL)',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentCtrl,
                    maxLines: 4,
                    minLines: 3,
                    maxLength: 500,
                    style: GoogleFonts.dmSans(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Share your experience...',
                      hintStyle: GoogleFonts.dmSans(
                        color: AppColors.textTertiary,
                        fontSize: 13,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.borderSolid,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.borderSolid,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.secondary,
                          width: 1.5,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (!_canSubmit)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Please rate all categories to submit.',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (!_canSubmit || _isSubmitting || order == null)
                          ? null
                          : () => _submit(order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.borderSolid,
                        disabledForegroundColor: AppColors.textTertiary,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Submit & complete order →',
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
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

  Future<void> _submit(OrderView order) async {
    final buyerId = ref.read(authStateProvider).value;
    if (buyerId == null) return;

    setState(() => _isSubmitting = true);

    final repo = ref.read(deliveryRepositoryProvider);
    final result = await repo.submitReviewAndClose(
      orderId: widget.orderId,
      buyerId: buyerId,
      agentId: order.agentId ?? '',
      overallRating: _overallRating,
      agentRating: _agentRating,
      communicationRating: _communicationRating,
      speedRating: _speedRating,
      comment: _commentCtrl.text.trim().isEmpty
          ? null
          : _commentCtrl.text.trim(),
    );

    if (mounted) setState(() => _isSubmitting = false);
    if (!mounted) return;

    result.fold((f) => _snackError(f.message), (_) => context.go('/home'));
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({
    required this.label,
    required this.description,
    required this.rating,
    required this.onRatingChanged,
  });

  final String label;
  final String description;
  final double rating;
  final void Function(double) onRatingChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          description,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(5, (i) {
            final star = i + 1;
            final filled = star <= rating;
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onRatingChanged(star.toDouble()),
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: Icon(
                        filled
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 36,
                        color: filled
                            ? const Color(0xFFFFB800)
                            : AppColors.borderSolid,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _SubmittedScreen extends StatelessWidget {
  final String orderId;
  final BuyerReviewModel review;

  const _SubmittedScreen({
    required this.orderId,
    required this.review,
  });

  static String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr',
      'May', 'Jun', 'Jul', 'Aug',
      'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final stars = review.overallRating.round().clamp(1, 5);

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
          ),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).pop(),
          style: IconButton.styleFrom(
            minimumSize: const Size(48, 48),
          ),
        ),
        title: Text(
          'Your review',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(
            height: 0.5,
            color: AppColors.borderSolid,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveLayout.contentMaxWidth(context),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              28,
              20,
              24 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9F4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.successMutedBorder,
                  width: 0.5,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.successMutedBackground,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      size: 28,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Thank you for your\nfeedback!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your review has been submitted\n'
                    'and helps us improve.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'YOUR RATING',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
                if (review.createdAt != null)
                  Text(
                    _SubmittedScreen._formatDate(review.createdAt!),
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(
                5,
                (i) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 36,
                    color: i < stars
                        ? const Color(0xFFFFB800)
                        : AppColors.borderSolid,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _ReadOnlyRatingRow(
              label: 'Agent performance',
              rating: review.agentRating,
            ),
            const SizedBox(height: 12),
            _ReadOnlyRatingRow(
              label: 'Communication',
              rating: review.communicationRating,
            ),
            const SizedBox(height: 12),
            _ReadOnlyRatingRow(
              label: 'Speed of service',
              rating: review.speedRating,
            ),
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'YOUR COMMENT',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.borderSolid,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  review.comment!,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Back to order',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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
  }
}

class _ReadOnlyRatingRow extends StatelessWidget {
  final String label;
  final double rating;

  const _ReadOnlyRatingRow({
    required this.label,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final stars = rating.round().clamp(1, 5);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 13.5,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Row(
          children: List.generate(
            5,
            (i) => Icon(
              i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 16,
              color: i < stars
                  ? const Color(0xFFFFB800)
                  : AppColors.borderSolid,
            ),
          ),
        ),
      ],
    );
  }
}
