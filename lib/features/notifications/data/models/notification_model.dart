// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/notification_entity.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

enum NotificationType {
  paymentRequest,
  paymentConfirmed,
  stageUpdate,
  orderCancelled,
  system,
  agentAssigned,
  bidWon,
  bidLost,
  shippingUpdate,
  arrival,
  orderEdited,
  inactivityReminder,
  newOrderAssigned,
  buyerMessage,
  buyerInactive24h,
  buyerInactive48h,
  buyerInactive72h,
  auctionDeadline,
  bidWonConfirmation,
  quoteApproved,
  quoteDeclined,
  repairDepositPaid,
  repairBalancePaid;

  static NotificationType fromString(String value) {
    const map = <String, NotificationType>{
      'payment_request': NotificationType.paymentRequest,
      'payment_confirmed': NotificationType.paymentConfirmed,
      'stage_update': NotificationType.stageUpdate,
      'order_cancelled': NotificationType.orderCancelled,
      'system': NotificationType.system,
      'agent_assigned': NotificationType.agentAssigned,
      'bid_won': NotificationType.bidWon,
      'bid_lost': NotificationType.bidLost,
      'shipping_update': NotificationType.shippingUpdate,
      'arrival': NotificationType.arrival,
      'order_edited': NotificationType.orderEdited,
      'inactivity_reminder': NotificationType.inactivityReminder,
      'new_order_assigned': NotificationType.newOrderAssigned,
      'buyer_message': NotificationType.buyerMessage,
      'buyer_inactive_24h': NotificationType.buyerInactive24h,
      'buyer_inactive_48h': NotificationType.buyerInactive48h,
      'buyer_inactive_72h': NotificationType.buyerInactive72h,
      'auction_deadline': NotificationType.auctionDeadline,
      'bid_won_confirmation': NotificationType.bidWonConfirmation,
      'quote_approved': NotificationType.quoteApproved,
      'quote_declined': NotificationType.quoteDeclined,
      'repair_deposit_paid': NotificationType.repairDepositPaid,
      'repair_balance_paid': NotificationType.repairBalancePaid,
    };
    return map[value] ?? NotificationType.system;
  }

  String get firestoreValue {
    const map = <NotificationType, String>{
      NotificationType.paymentRequest: 'payment_request',
      NotificationType.paymentConfirmed: 'payment_confirmed',
      NotificationType.stageUpdate: 'stage_update',
      NotificationType.orderCancelled: 'order_cancelled',
      NotificationType.system: 'system',
      NotificationType.agentAssigned: 'agent_assigned',
      NotificationType.bidWon: 'bid_won',
      NotificationType.bidLost: 'bid_lost',
      NotificationType.shippingUpdate: 'shipping_update',
      NotificationType.arrival: 'arrival',
      NotificationType.orderEdited: 'order_edited',
      NotificationType.inactivityReminder: 'inactivity_reminder',
      NotificationType.newOrderAssigned: 'new_order_assigned',
      NotificationType.buyerMessage: 'buyer_message',
      NotificationType.buyerInactive24h: 'buyer_inactive_24h',
      NotificationType.buyerInactive48h: 'buyer_inactive_48h',
      NotificationType.buyerInactive72h: 'buyer_inactive_72h',
      NotificationType.auctionDeadline: 'auction_deadline',
      NotificationType.bidWonConfirmation: 'bid_won_confirmation',
      NotificationType.quoteApproved: 'quote_approved',
      NotificationType.quoteDeclined: 'quote_declined',
      NotificationType.repairDepositPaid: 'repair_deposit_paid',
      NotificationType.repairBalancePaid: 'repair_balance_paid',
    };
    return map[this] ?? 'system';
  }
}

NotificationType _notificationTypeFromJson(Object? json) =>
    NotificationType.fromString(json as String? ?? 'system');

String _notificationTypeToJson(NotificationType t) => t.firestoreValue;

@freezed
class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required String id,
    required String userId,
    String? orderId,
    String? orderRef,
    @JsonKey(
      fromJson: _notificationTypeFromJson,
      toJson: _notificationTypeToJson,
    )
    required NotificationType type,
    required String title,
    required String body,
    String? actionUrl,
    @Default(false) bool isRead,
    DateTime? sentAt,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return NotificationModel(
        id: doc.id,
        userId: '',
        type: NotificationType.system,
        title: '',
        body: '',
      );
    }
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      orderId: data['orderId'] as String?,
      orderRef: data['orderRef'] as String?,
      type: NotificationType.fromString(
        data['type'] as String? ?? 'system',
      ),
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      actionUrl: data['actionUrl'] as String?,
      isRead: data['isRead'] as bool? ?? false,
      sentAt: (data['sentAt'] as Timestamp?)?.toDate(),
    );
  }
}

extension NotificationModelEntityX on NotificationModel {
  NotificationEntity toNotificationEntity() {
    return NotificationEntity(
      id: id,
      userId: userId,
      orderId: orderId,
      type: type.firestoreValue,
      title: title,
      body: body,
      actionUrl: actionUrl,
      isRead: isRead,
      sentAt: sentAt ?? DateTime.now(),
    );
  }
}

/// Backwards-compatible mapper used by [NotificationsFirestoreDataSource].
NotificationEntity notificationFromDoc(DocumentSnapshot doc) {
  return NotificationModel.fromFirestore(doc).toNotificationEntity();
}
