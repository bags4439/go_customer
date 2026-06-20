import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../layout/app_breakpoints.dart';
import '../theme/app_colors.dart';
import '../../router.dart';

/// Visual configuration for [AppTopBanner].
class AppTopBannerAppearance {
  const AppTopBannerAppearance({
    required this.icon,
    required this.accent,
    required this.accentBg,
  });

  final IconData icon;
  final Color accent;
  final Color accentBg;

  static const info = AppTopBannerAppearance(
    icon: Icons.info_outline_rounded,
    accent: AppColors.infoText,
    accentBg: AppColors.infoBackground,
  );
}

/// Shows a top slide-in banner above all routes via the root overlay.
///
/// Used for session notices and foreground push notifications.
void showAppTopBanner({
  String title = '',
  required String body,
  AppTopBannerAppearance appearance = AppTopBannerAppearance.info,
  Duration duration = const Duration(seconds: 5),
  VoidCallback? onTap,
}) {
  final overlay = rootNavigatorKey.currentState?.overlay;
  if (overlay == null) return;

  OverlayEntry? entry;

  void remove() {
    entry?.remove();
    entry = null;
  }

  entry = OverlayEntry(
    builder: (context) => AppTopBanner(
      title: title,
      body: body,
      appearance: appearance,
      duration: duration,
      onTap: onTap,
      onDismiss: remove,
    ),
  );

  overlay.insert(entry!);
}

/// Top slide-in notice banner with dismiss, swipe-up, and auto-dismiss progress.
class AppTopBanner extends StatefulWidget {
  const AppTopBanner({
    super.key,
    this.title = '',
    required this.body,
    required this.appearance,
    required this.duration,
    required this.onDismiss,
    this.onTap,
  });

  final String title;
  final String body;
  final AppTopBannerAppearance appearance;
  final Duration duration;
  final VoidCallback onDismiss;
  final VoidCallback? onTap;

  @override
  State<AppTopBanner> createState() => _AppTopBannerState();
}

class _AppTopBannerState extends State<AppTopBanner>
    with TickerProviderStateMixin {
  late final AnimationController _slideCtrl;
  late final AnimationController _progressCtrl;
  late final Animation<Offset> _slideAnim;
  bool _dismissing = false;
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));

    _progressCtrl = AnimationController(vsync: this, duration: widget.duration);

    _slideCtrl.forward();
    _progressCtrl.forward();
    _progressCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) _dismiss();
    });
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (_dismissing) return;
    _dismissing = true;
    _progressCtrl.stop();
    await _slideCtrl.reverse();
    widget.onDismiss();
  }

  void _handleTap() {
    widget.onTap?.call();
    _dismiss();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    final maxWidth = AppBreakpoints.isWeb(context) ? 520.0 : double.infinity;
    final hasTitle = widget.title.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: topPad + 10,
            left: 16,
            right: 16,
            child: SlideTransition(
              position: _slideAnim,
              child: Transform.translate(
                offset: Offset(0, _dragOffset),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: GestureDetector(
                      onTap: widget.onTap == null ? null : _handleTap,
                      onVerticalDragUpdate: (details) {
                        if (details.delta.dy < 0) {
                          setState(() {
                            _dragOffset += details.delta.dy * 0.6;
                          });
                        }
                      },
                      onVerticalDragEnd: (details) {
                        if (_dragOffset < -20 ||
                            (details.primaryVelocity ?? 0) < -300) {
                          _dismiss();
                        } else {
                          setState(() => _dragOffset = 0);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.borderSolid,
                            width: 0.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(14, 14, 6, 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: widget.appearance.accentBg,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        widget.appearance.icon,
                                        color: widget.appearance.accent,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (hasTitle) ...[
                                            Text(
                                              widget.title,
                                              style: GoogleFonts.dmSans(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary,
                                                height: 1.2,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (widget.body.isNotEmpty)
                                              const SizedBox(height: 3),
                                          ],
                                          if (widget.body.isNotEmpty)
                                            Text(
                                              widget.body,
                                              style: GoogleFonts.dmSans(
                                                fontSize: hasTitle ? 12 : 14,
                                                fontWeight: hasTitle
                                                    ? FontWeight.w400
                                                    : FontWeight.w500,
                                                color: hasTitle
                                                    ? AppColors.textSecondary
                                                    : AppColors.textPrimary,
                                                height: 1.4,
                                              ),
                                              maxLines: hasTitle ? 2 : 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _dismiss,
                                      style: IconButton.styleFrom(
                                        minimumSize: const Size(48, 48),
                                        padding: EdgeInsets.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        size: 16,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedBuilder(
                                animation: _progressCtrl,
                                builder: (context, _) {
                                  return LinearProgressIndicator(
                                    value: 1.0 - _progressCtrl.value,
                                    minHeight: 2,
                                    backgroundColor: AppColors.borderSolid,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      widget.appearance.accent,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
