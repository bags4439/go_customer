import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/guide_providers.dart';
import 'coach_mark_card.dart';
import 'spotlight_painter.dart';

/// The full coach mark overlay. Place this on top
/// of your screen's widget tree using an Overlay
/// or Stack. It handles:
/// - Animated spotlight opening
/// - Dark scrim with cutout
/// - Floating info card
/// - Auto-marking the guide key as seen on dismiss
///
/// Usage:
/// ```dart
/// CoachMarkOverlay(
///   guideKey: GuideKeys.homeEmpty,
///   targetKey: _buttonKey,
///   title: 'Import your first car',
///   body: 'Tap here to tell us what car...',
///   spotlightShape: SpotlightShape.roundedRect,
///   onDismiss: () => setState(() => _showGuide = false),
/// )
/// ```
class CoachMarkOverlay extends ConsumerStatefulWidget {
  const CoachMarkOverlay({
    super.key,
    required this.guideKey,
    required this.targetKey,
    required this.title,
    required this.body,
    required this.spotlightShape,
    required this.onDismiss,
    this.onNext,
    this.cardPosition = CardPosition.auto,
    this.showFaqLink = true,
    this.onFaqTap,
    this.spotlightPadding = 10.0,
    this.dismissLabel,
  });

  /// The GuideKeys constant for this touchpoint.
  /// Marked as seen automatically on dismiss.
  final String guideKey;

  /// GlobalKey attached to the widget to spotlight.
  final GlobalKey targetKey;

  final String title;
  final String body;
  final SpotlightShape spotlightShape;

  /// Called after the guide is dismissed and
  /// marked as seen.
  final VoidCallback onDismiss;

  /// When non-null, shows "Next →" button.
  final VoidCallback? onNext;

  final CardPosition cardPosition;
  final bool showFaqLink;
  final VoidCallback? onFaqTap;
  final double spotlightPadding;
  final String? dismissLabel;

  @override
  ConsumerState<CoachMarkOverlay> createState() => _CoachMarkOverlayState();
}

class _CoachMarkOverlayState extends ConsumerState<CoachMarkOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  Rect? _targetRect;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureTarget();
      _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _measureTarget() {
    final ctx = widget.targetKey.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final pos = box.localToGlobal(Offset.zero);
    setState(() {
      _targetRect = pos & box.size;
    });
  }

  Future<void> _dismiss() async {
    await _ctrl.reverse();
    await ref.read(guideNotifierProvider.notifier).markSeen(widget.guideKey);
    widget.onDismiss();
  }

  void _onNext() {
    ref.read(guideNotifierProvider.notifier).markSeen(widget.guideKey).then((
      _,
    ) {
      if (!mounted) return;
      widget.onNext?.call();
    });
  }

  CardPosition _resolvedCardPosition(Size screenSize) {
    if (widget.cardPosition != CardPosition.auto) {
      return widget.cardPosition;
    }
    final rect = _targetRect;
    if (rect == null) return CardPosition.below;
    return rect.center.dy > screenSize.height / 2
        ? CardPosition.above
        : CardPosition.below;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final rect = _targetRect;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            if (rect != null)
              RepaintBoundary(
                child: CustomPaint(
                  size: size,
                  painter: SpotlightPainter(
                    targetRect: rect,
                    shape: widget.spotlightShape,
                    progress: _anim.value,
                    padding: widget.spotlightPadding,
                  ),
                ),
              )
            else
              Opacity(
                opacity: _anim.value * 0.65,
                child: const ColoredBox(color: Colors.black),
              ),
            Positioned.fill(
              child: GestureDetector(
                onTap: _dismiss,
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.expand(),
              ),
            ),
            if (_anim.value > 0.3) _buildCard(size),
          ],
        );
      },
    );
  }

  Widget _buildCard(Size screenSize) {
    final cardPosition = _resolvedCardPosition(screenSize);
    final rect = _targetRect;
    const cardHPad = 20.0;
    const cardGap = 16.0;

    double? top;
    double? bottom;

    if (rect != null) {
      if (cardPosition == CardPosition.below) {
        top = rect.bottom + widget.spotlightPadding + cardGap;
      } else {
        bottom =
            screenSize.height - rect.top + widget.spotlightPadding + cardGap;
      }
    } else {
      top = screenSize.height * 0.55;
    }

    return Positioned(
      left: cardHPad,
      right: cardHPad,
      top: top,
      bottom: bottom,
      child: FadeTransition(
        opacity: _anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, cardPosition == CardPosition.below ? 0.1 : -0.1),
            end: Offset.zero,
          ).animate(_anim),
          child: CoachMarkCard(
            title: widget.title,
            body: widget.body,
            onDismiss: _dismiss,
            onNext: widget.onNext != null ? _onNext : null,
            showFaqLink: widget.showFaqLink,
            onFaqTap: widget.onFaqTap,
            dismissLabel: widget.dismissLabel,
          ),
        ),
      ),
    );
  }
}

/// Convenience mixin for screens that show a
/// single coach mark. Manages the show/hide state
/// and auto-triggers on first mount.
///
/// Usage:
/// ```dart
/// class _MyScreenState extends ConsumerState<MyScreen>
///     with CoachMarkMixin<MyScreen> {
///
///   final _targetKey = GlobalKey();
///
///   @override
///   String get coachMarkKey => GuideKeys.myKey;
///
///   @override
///   Widget build(BuildContext context) {
///     return Stack(
///       children: [
///         // ... screen content with _targetKey ...
///         if (showCoachMark)
///           CoachMarkOverlay(
///             guideKey: coachMarkKey,
///             targetKey: _targetKey,
///             ...
///             onDismiss: hideCoachMark,
///           ),
///       ],
///     );
///   }
/// }
/// ```
mixin CoachMarkMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool _showCoachMark = false;

  bool get showCoachMark => _showCoachMark;

  /// The GuideKeys constant for this screen.
  String get coachMarkKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShow();
    });
  }

  Future<void> _checkAndShow() async {
    final result = await ref
        .read(hasSeenGuideUseCaseProvider)
        .call(coachMarkKey);
    final seen = result.fold((_) => true, (v) => v);
    if (!seen && mounted) {
      setState(() => _showCoachMark = true);
    }
  }

  void hideCoachMark() {
    if (mounted) {
      setState(() => _showCoachMark = false);
    }
  }

  void showCoachMarkManually() {
    if (mounted) {
      setState(() => _showCoachMark = true);
    }
  }
}
