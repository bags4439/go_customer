import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../core/utils/onesignal_web_helper.dart';
import '../../../../router.dart';
import '../core/constants/notification_constants.dart';

/// Call on user logout so OneSignal stops associating notifications with the user.
void clearOneSignalUser() {
  if (kIsWeb) {
    oneSignalWebLogout();
    return;
  }
  try {
    OneSignal.logout();
  } catch (_) {}
}

/// Configures OneSignal notification opened and foreground display.
/// Call once from main after OneSignal.initialize.
void setupNotificationHandlers(GoRouter router) {
  OneSignal.Notifications.addClickListener((event) {
    _handleNotificationOpened(router, event.notification);
  });

  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    final location = router.routerDelegate.currentConfiguration.fullPath;
    if (location.startsWith('/notifications')) {
      event.preventDefault();
      return;
    }
    event.preventDefault();

    final data = event.notification.additionalData;
    final type = data?['type'] is String ? data!['type'] as String : null;

    _showInAppBanner(
      title: event.notification.title ?? NotificationConstants.appBarTitle,
      body: event.notification.body ?? '',
      actionUrl: _actionUrlFromNotification(event.notification),
      notificationId: _notificationIdFromNotification(event.notification),
      type: type,
      router: router,
    );
  });
}

void _handleNotificationOpened(GoRouter router, OSNotification notification) {
  final actionUrl = _actionUrlFromNotification(notification);
  if (actionUrl != null && actionUrl.isNotEmpty) {
    router.push(actionUrl);
  }
  final id = _notificationIdFromNotification(notification);
  if (id != null && id.isNotEmpty) {
    _markNotificationRead(id);
  }
}

String? _actionUrlFromNotification(OSNotification notification) {
  final data = notification.additionalData;
  if (data == null) return null;
  final url = data['actionUrl'];
  return url is String ? url : null;
}

String? _notificationIdFromNotification(OSNotification notification) {
  final data = notification.additionalData;
  if (data == null) return null;
  final id = data['notificationId'] ?? data['id'];
  if (id is String) return id;
  return null;
}

Future<void> _markNotificationRead(String notificationId) async {
  try {
    await FirebaseFirestore.instance
        .collection(FirestoreCollections.notifications)
        .doc(notificationId)
        .update({'isRead': true});
  } catch (_) {}
}

void _showInAppBanner({
  required String title,
  required String body,
  required String? actionUrl,
  required String? notificationId,
  required String? type,
  required GoRouter router,
}) {
  final overlay = rootNavigatorKey.currentState?.overlay;
  if (overlay == null) return;

  OverlayEntry? entry;

  void remove() {
    entry?.remove();
    entry = null;
  }

  void onTap() {
    remove();
    if (actionUrl != null && actionUrl.isNotEmpty) {
      router.push(actionUrl);
    }
    if (notificationId != null && notificationId.isNotEmpty) {
      _markNotificationRead(notificationId);
    }
  }

  entry = OverlayEntry(
    builder: (context) => _NotificationBanner(
      title: title,
      body: body,
      type: type,
      onTap: onTap,
      onDismiss: remove,
    ),
  );

  overlay.insert(entry!);
}

// ── Banner widget ─────────────────────────────────────────

class _NotificationBanner extends StatefulWidget {
  const _NotificationBanner({
    required this.title,
    required this.body,
    required this.type,
    required this.onTap,
    required this.onDismiss,
  });

  final String title;
  final String body;
  final String? type;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  State<_NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<_NotificationBanner>
    with TickerProviderStateMixin {
  late final AnimationController _slideCtrl;
  late final AnimationController _progressCtrl;
  late final Animation<Offset> _slideAnim;
  bool _dismissing = false;
  double _dragOffset = 0;

  static const _duration = Duration(seconds: 5);

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

    _progressCtrl = AnimationController(vsync: this, duration: _duration);

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

  ({IconData icon, Color accent, Color accentBg}) get _config {
    switch (widget.type) {
      case 'agent_assigned':
        return (
          icon: Icons.person_rounded,
          accent: AppColors.secondary,
          accentBg: AppColors.selectionTint,
        );
      case 'bid_won':
        return (
          icon: Icons.emoji_events_rounded,
          accent: AppColors.success,
          accentBg: AppColors.successMutedBackground,
        );
      case 'bid_lost':
        return (
          icon: Icons.info_rounded,
          accent: AppColors.warning,
          accentBg: AppColors.amberBackground,
        );
      case 'arrival':
        return (
          icon: Icons.anchor_rounded,
          accent: AppColors.secondary,
          accentBg: AppColors.selectionTint,
        );
      case 'repair_quote':
        return (
          icon: Icons.build_rounded,
          accent: AppColors.warning,
          accentBg: AppColors.amberBackground,
        );
      case 'quote_approved':
        return (
          icon: Icons.build_rounded,
          accent: AppColors.success,
          accentBg: AppColors.successMutedBackground,
        );
      case 'payment_request':
        return (
          icon: Icons.credit_card_rounded,
          accent: AppColors.danger,
          accentBg: AppColors.dangerMutedBackground,
        );
      case 'payment_confirmed':
        return (
          icon: Icons.check_circle_rounded,
          accent: AppColors.success,
          accentBg: AppColors.successMutedBackground,
        );
      case 'order_cancelled':
        return (
          icon: Icons.cancel_rounded,
          accent: AppColors.danger,
          accentBg: AppColors.dangerMutedBackground,
        );
      case 'delivery_location_set':
        return (
          icon: Icons.location_on_rounded,
          accent: AppColors.success,
          accentBg: AppColors.successMutedBackground,
        );
      case 'delivery_confirmed':
        return (
          icon: Icons.local_shipping_rounded,
          accent: AppColors.success,
          accentBg: AppColors.successMutedBackground,
        );
      case 'stage_update':
      default:
        return (
          icon: Icons.notifications_rounded,
          accent: AppColors.secondary,
          accentBg: AppColors.selectionTint,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    final cfg = _config;

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
                child: GestureDetector(
                  onTap: widget.onTap,
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
                            padding: const EdgeInsets.fromLTRB(14, 14, 6, 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: cfg.accentBg,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    cfg.icon,
                                    color: cfg.accent,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
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
                                      if (widget.body.isNotEmpty) ...[
                                        const SizedBox(height: 3),
                                        Text(
                                          widget.body,
                                          style: GoogleFonts.dmSans(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                            height: 1.4,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
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
                                  cfg.accent,
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
        ],
      ),
    );
  }
}
