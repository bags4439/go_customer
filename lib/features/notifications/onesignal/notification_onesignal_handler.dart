import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_top_banner.dart';
import '../../../core/utils/onesignal_web_helper.dart';
import '../core/constants/notification_constants.dart';
import 'notification_banner_appearance.dart';

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
  showAppTopBanner(
    title: title,
    body: body,
    appearance: notificationBannerAppearance(type),
    onTap: () {
      if (actionUrl != null && actionUrl.isNotEmpty) {
        router.push(actionUrl);
      }
      if (notificationId != null && notificationId.isNotEmpty) {
        _markNotificationRead(notificationId);
      }
    },
  );
}
