import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/firebase_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/notifications_firestore_data_source.dart';
import '../../data/models/notification_model.dart';
import '../../domain/entities/notification_entity.dart';
import '../models/notification_list_item.dart';

enum NotificationFilter {
  all,
  payments,
  orderUpdates,
  messages,
  alerts,
}

class NotificationsState {
  final List<NotificationEntity> items;
  final DocumentSnapshot<Map<String, dynamic>>? lastDoc;
  final bool hasMore;
  final bool isLoadingMore;
  final Object? streamError;

  const NotificationsState({
    this.items = const [],
    this.lastDoc,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.streamError,
  });

  NotificationsState copyWith({
    List<NotificationEntity>? items,
    DocumentSnapshot<Map<String, dynamic>>? lastDoc,
    bool? hasMore,
    bool? isLoadingMore,
    Object? streamError,
  }) {
    return NotificationsState(
      items: items ?? this.items,
      lastDoc: lastDoc ?? this.lastDoc,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      streamError: streamError,
    );
  }
}

final notificationsDataSourceProvider =
    Provider<NotificationsFirestoreDataSource>((ref) {
  return NotificationsFirestoreDataSource(ref.watch(firestoreProvider));
});

final notificationsNotifierProvider =
    NotifierProvider<NotificationsNotifier, AsyncValue<NotificationsState>>(
  NotificationsNotifier.new,
);

class NotificationsNotifier extends Notifier<AsyncValue<NotificationsState>> {
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  String? _subscribedUserId;
  bool _disposeHooked = false;

  @override
  AsyncValue<NotificationsState> build() {
    final userId = ref.watch(authStateProvider).valueOrNull;
    if (userId == null || userId.isEmpty) {
      _subscription?.cancel();
      _subscription = null;
      _subscribedUserId = null;
      return const AsyncValue.data(NotificationsState());
    }

    if (!_disposeHooked) {
      _disposeHooked = true;
      ref.onDispose(() {
        _subscription?.cancel();
        _subscription = null;
        _subscribedUserId = null;
      });
    }

    // Rebuilds (e.g. auth stream tick) must not reset to loading or the list
    // disappears until the next snapshot; keep the same subscription + state.
    if (_subscribedUserId == userId && _subscription != null) {
      return state;
    }

    _subscription?.cancel();
    _subscribedUserId = userId;
    _subscribe(userId);
    return const AsyncValue.loading();
  }

  void _subscribe(String userId) {
    final dataSource = ref.read(notificationsDataSourceProvider);
    _subscription?.cancel();
    _subscription = dataSource.watchNotificationsStream(userId).listen(
      (snapshot) {
        final list = snapshot.docs
            .map((d) =>
                notificationFromDoc(d as DocumentSnapshot<Map<String, dynamic>>))
            .toList();
        final lastDoc = snapshot.docs.isNotEmpty
            ? snapshot.docs.last as DocumentSnapshot<Map<String, dynamic>>
            : null;
        final prev = state.valueOrNull;
        final merged = prev != null && prev.items.length > list.length
            ? [...list, ...prev.items.sublist(list.length)]
            : list;
        state = AsyncValue.data(NotificationsState(
          items: merged,
          lastDoc: lastDoc,
          hasMore: snapshot.docs.length >= 50,
        ));
      },
      onError: (e, st) {
        state = AsyncValue.data(NotificationsState(streamError: e));
      },
    );
  }

  Future<void> loadMore(String userId) async {
    final current = state.valueOrNull;
    if (current == null ||
        current.isLoadingMore ||
        !current.hasMore ||
        current.lastDoc == null) {
      return;
    }

    state = AsyncValue.data(
      current.copyWith(isLoadingMore: true),
    );
    final dataSource = ref.read(notificationsDataSourceProvider);
    try {
      final (nextPage, newLastDoc) = await dataSource.fetchPageAfter(
        userId,
        startAfterDocument: current.lastDoc,
      );
      final updated = state.valueOrNull;
      if (updated == null) {
        return;
      }
      state = AsyncValue.data(updated.copyWith(
        items: [...updated.items, ...nextPage],
        lastDoc: newLastDoc,
        hasMore: nextPage.length >= 50,
        isLoadingMore: false,
      ));
    } catch (e) {
      final updated = state.valueOrNull;
      if (updated != null) {
        state = AsyncValue.data(updated.copyWith(isLoadingMore: false));
      }
    }
  }

  Future<void> markRead(String notificationId) async {
    final dataSource = ref.read(notificationsDataSourceProvider);
    dataSource.markRead(notificationId);
  }

  Future<void> markAllRead(List<String> notificationIds) async {
    if (notificationIds.isEmpty) return;
    final dataSource = ref.read(notificationsDataSourceProvider);
    await dataSource.markAllRead(notificationIds);
  }
}

/// Filter applied client-side.
List<NotificationEntity> filterNotifications(
  List<NotificationEntity> items,
  NotificationFilter filter,
) {
  switch (filter) {
    case NotificationFilter.all:
      return items;
    case NotificationFilter.payments:
      return items
          .where((n) =>
              n.type == 'payment_request' || n.type == 'payment_confirmed')
          .toList();
    case NotificationFilter.orderUpdates:
      return items
          .where((n) => [
                'bid_won',
                'bid_lost',
                'stage_update',
                'agent_assigned',
                'order_edited',
                'order_cancelled',
                'arrival',
                'shipping_update',
              ].contains(n.type))
          .toList();
    case NotificationFilter.messages:
      return items.where((n) => n.type == 'message').toList();
    case NotificationFilter.alerts:
      return items
          .where((n) => [
                'inactivity_reminder',
                'auction_deadline',
                'id_reminder',
                'system',
              ].contains(n.type))
          .toList();
  }
}

final notificationFilterProvider =
    StateProvider<NotificationFilter>((ref) => NotificationFilter.all);

final markAllReadInProgressProvider = StateProvider<bool>((ref) => false);

/// When non-null, these ids are being marked read; UI shows optimistic read state
/// with staggered animation. Cleared when animation completes.
final markAllReadIdsProvider = StateProvider<List<String>?>((ref) => null);

final filteredNotificationsProvider =
    Provider.family<List<NotificationEntity>, NotificationFilter>((ref, filter) {
  final asyncState = ref.watch(notificationsNotifierProvider);
  final list = asyncState.valueOrNull?.items ?? const [];
  return filterNotifications(list, filter);
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final asyncState = ref.watch(notificationsNotifierProvider);
  final items = asyncState.valueOrNull?.items ?? const [];
  return items.where((n) => !n.isRead).length;
});

final unreadCountByFilterProvider =
    Provider.family<bool, NotificationFilter>((ref, filter) {
  final asyncState = ref.watch(notificationsNotifierProvider);
  final items = asyncState.valueOrNull?.items ?? const [];
  final filtered = filterNotifications(items, filter);
  return filtered.any((n) => !n.isRead);
});

final groupedNotificationsProvider =
    Provider.family<Map<String, List<NotificationEntity>>, NotificationFilter>(
  (ref, filter) {
    final filtered = ref.watch(filteredNotificationsProvider(filter));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final Map<String, List<NotificationEntity>> result = {
      'Today': [],
      'Yesterday': [],
      'Earlier': [],
    };
    for (final n in filtered) {
      final d = DateTime(n.sentAt.year, n.sentAt.month, n.sentAt.day);
      if (d == today) {
        result['Today']!.add(n);
      } else if (d == yesterday) {
        result['Yesterday']!.add(n);
      } else {
        result['Earlier']!.add(n);
      }
    }
    return result;
  },
);

/// Flat list of NotificationListItem (section header or entry) for ListView.builder.
final notificationListItemsProvider =
    Provider.family<List<NotificationListItem>, NotificationFilter>((ref, filter) {
  final grouped = ref.watch(groupedNotificationsProvider(filter));
  final list = <NotificationListItem>[];
  for (final entry in grouped.entries) {
    if (entry.value.isEmpty) continue;
    list.add(NotificationListItemSection(entry.key));
    for (final n in entry.value) {
      list.add(NotificationListItemEntry(n));
    }
  }
  return list;
});
