import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../router.dart';
import '../core/constants/notification_constants.dart';

/// Call on user logout so OneSignal stops associating notifications with the user.
void clearOneSignalUser() {
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
    _showInAppBanner(
      title: event.notification.title ?? NotificationConstants.appBarTitle,
      body: event.notification.body ?? '',
      actionUrl: _actionUrlFromNotification(event.notification),
      notificationId: _notificationIdFromNotification(event.notification),
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
  required GoRouter router,
}) {
  final overlay = rootNavigatorKey.currentState?.overlay;
  if (overlay == null) return;

  OverlayEntry? entry;
  Timer? dismissTimer;

  void remove() {
    dismissTimer?.cancel();
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
    builder: (context) => Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A18),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (body.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            body,
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry!);
  dismissTimer = Timer(const Duration(seconds: 4), remove);
}
