import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/layout/dashboard_layout.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_button_styles.dart';
import '../../../../core/widgets/dashboard_mobile_app_bar.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../delivery/presentation/providers/delivery_providers.dart';
import '../../../orders/data/models/buyer_review_model.dart';
import '../providers/order_detail_providers.dart';
import '../providers/order_providers.dart';
import '../widgets/order_detail/order_detail_web_panel_chrome.dart';

class BuyerReviewScreen extends ConsumerStatefulWidget {
  const BuyerReviewScreen({
    super.key,
    required this.orderId,
    this.embedInWebPanel = false,
    this.onClosePanel,
  });

  final String orderId;
  final bool embedInWebPanel;
  final VoidCallback? onClosePanel;

  @override
  ConsumerState<BuyerReviewScreen> createState() => _BuyerReviewScreenState();
}

class _BuyerReviewScreenState extends ConsumerState<BuyerReviewScreen> {
  double _overallRating = 0;
  final _commentCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit => _overallRating > 0;

  void _snackError(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
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
    final deliveryAsync = ref.watch(deliveryProvider(widget.orderId));
    final delivery = deliveryAsync.valueOrNull;

    final reviewAsync = userId != null
        ? ref.watch(
            buyerReviewProvider((orderId: widget.orderId, buyerId: userId)),
          )
        : null;
    final existingReview = reviewAsync?.valueOrNull;

    if (existingReview != null) {
      return _SubmittedScreen(
        orderId: widget.orderId,
        review: existingReview,
        embedInWebPanel: widget.embedInWebPanel,
        onClosePanel: widget.onClosePanel,
      );
    }

    final canReview = order?.status == AppConstants.statusDeliveryConfirmed ||
        delivery?.isConfirmed == true;

    if (order != null && !canReview) {
      return _GateScreen(
        orderId: widget.orderId,
        embedInWebPanel: widget.embedInWebPanel,
        onClosePanel: widget.onClosePanel,
      );
    }

    final form = Center(
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
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.successMutedBackground, AppColors.successGradientLight],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        size: 34,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'How was your experience?',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.successHeroDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your feedback helps us improve and recognises '
                      'your agent\'s work.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.successHeroMid,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'OVERALL RATING',
                style: AppTextStyles.labelSmall.copyWith(
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 16),
              _PremiumStarRow(
                rating: _overallRating,
                onRatingChanged: (r) => setState(() => _overallRating = r),
              ),
              if (_overallRating > 0) ...[
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    _ratingLabel(_overallRating),
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 28),
              Text(
                'COMMENTS (OPTIONAL)',
                style: AppTextStyles.labelSmall.copyWith(
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _commentCtrl,
                maxLines: 4,
                minLines: 3,
                maxLength: 500,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Tell us what stood out…',
                  hintStyle: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.borderSolid,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.borderSolid,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.secondary,
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: (!_canSubmit || _isSubmitting || order == null)
                      ? null
                      : () => _submit(order),
                  style: AppButtonStyles.primary(
                    enabled:
                        _canSubmit && !_isSubmitting && order != null,
                    minimumHeight: 52,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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
                          style: AppTextStyles.buttonLarge,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.embedInWebPanel) {
      final orderRef = order?.orderRef ?? widget.orderId;
      return OrderDetailWebPanelChrome(
        title: 'Rate your experience',
        orderRef: orderRef,
        onBack: widget.onClosePanel ?? () => resetWebOrderPanelTask(ref),
        child: form,
      );
    }

    return PopScope(
      canPop: !_isSubmitting,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: DashboardMobileTitleAppBar(
          title: 'Rate your experience',
          onBack: _isSubmitting ? null : () => Navigator.of(context).pop(),
          titleStyle: AppTextStyles.titleMedium.copyWith(
            fontSize: 18,
            color: AppColors.foreground,
          ),
        ),
        body: DashboardPortraitFrame(child: form),
      ),
    );
  }

  String _ratingLabel(double rating) {
    return switch (rating.round()) {
      5 => 'Excellent — thank you!',
      4 => 'Great experience',
      3 => 'Good, with room to improve',
      2 => 'Below expectations',
      1 => 'Poor experience',
      _ => '',
    };
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
      comment: _commentCtrl.text.trim().isEmpty
          ? null
          : _commentCtrl.text.trim(),
    );

    if (mounted) setState(() => _isSubmitting = false);
    if (!mounted) return;

    result.fold(
      (f) => _snackError(f.message),
      (_) {
        if (widget.embedInWebPanel) {
          resetWebOrderPanelTask(ref);
        }
        context.go('/home');
      },
    );
  }
}

class _PremiumStarRow extends StatelessWidget {
  const _PremiumStarRow({
    required this.rating,
    required this.onRatingChanged,
  });

  final double rating;
  final void Function(double) onRatingChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final star = i + 1;
        final filled = star <= rating;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onRatingChanged(star.toDouble()),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: filled
                      ? AppColors.ratingStar.withValues(alpha: 0.12)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: filled
                        ? AppColors.ratingStar.withValues(alpha: 0.5)
                        : AppColors.borderSolid,
                  ),
                ),
                child: Center(
                  child: Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 32,
                    color: filled
                        ? AppColors.ratingStar
                        : AppColors.textTertiary,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _GateScreen extends StatelessWidget {
  const _GateScreen({
    required this.orderId,
    this.embedInWebPanel = false,
    this.onClosePanel,
  });

  final String orderId;
  final bool embedInWebPanel;
  final VoidCallback? onClosePanel;

  @override
  Widget build(BuildContext context) {
    final body = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ResponsiveLayout.contentMaxWidth(context),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.infoBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  size: 36,
                  color: AppColors.infoText,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Confirm receipt first',
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please confirm you received your vehicle before '
                'leaving a review.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    if (embedInWebPanel) {
                      onClosePanel?.call();
                    } else {
                      context.push('/order/$orderId/delivery');
                    }
                  },
                  style: AppButtonStyles.primary(
                    minimumHeight: 52,
                    shape: AppButtonStyles.roundedMdShape,
                  ),
                  child: Text(
                    'Go to delivery →',
                    style: AppTextStyles.buttonMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (embedInWebPanel) {
      return OrderDetailWebPanelChrome(
        title: 'Rate your experience',
        orderRef: orderId,
        onBack: onClosePanel ?? () {},
        child: body,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: DashboardMobileTitleAppBar(
        title: 'Rate your experience',
        onBack: () => Navigator.of(context).pop(),
        titleStyle: AppTextStyles.titleMedium.copyWith(fontSize: 18),
      ),
      body: DashboardPortraitFrame(child: body),
    );
  }
}

class _SubmittedScreen extends ConsumerWidget {
  final String orderId;
  final BuyerReviewModel review;
  final bool embedInWebPanel;
  final VoidCallback? onClosePanel;

  const _SubmittedScreen({
    required this.orderId,
    required this.review,
    this.embedInWebPanel = false,
    this.onClosePanel,
  });

  static String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stars = review.overallRating.round().clamp(1, 5);

    final body = Center(
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
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.successSurfaceLight, AppColors.successMutedBackground],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.successMutedBorder,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Thank you!',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your review has been submitted.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('YOUR RATING', style: AppTextStyles.labelSmall),
                  if (review.createdAt != null)
                    Text(
                      _formatDate(review.createdAt!),
                      style: AppTextStyles.caption,
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: List.generate(
                  5,
                  (i) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(
                      i < stars
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 36,
                      color: i < stars
                          ? AppColors.ratingStar
                          : AppColors.borderSolid,
                    ),
                  ),
                ),
              ),
              if (review.comment != null && review.comment!.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('YOUR COMMENT', style: AppTextStyles.labelSmall),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderSolid),
                  ),
                  child: Text(
                    review.comment!,
                    style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: () {
                    if (embedInWebPanel) {
                      resetWebOrderPanelTask(ref);
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  style: AppButtonStyles.primary(
                    minimumHeight: 52,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Back to order',
                    style: AppTextStyles.buttonLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (embedInWebPanel) {
      return OrderDetailWebPanelChrome(
        title: 'Your review',
        orderRef: orderId,
        onBack: onClosePanel ?? () => resetWebOrderPanelTask(ref),
        child: body,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: DashboardMobileTitleAppBar(
        title: 'Your review',
        onBack: () => Navigator.of(context).pop(),
        titleStyle: AppTextStyles.titleMedium.copyWith(
          fontSize: 18,
          color: AppColors.foreground,
        ),
      ),
      body: DashboardPortraitFrame(child: body),
    );
  }
}
