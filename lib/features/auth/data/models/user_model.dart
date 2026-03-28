import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/app_user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String fullName,
    required String phone,
    String? email,
    required String role, // 'buyer' | 'agent' | 'admin'
    String? location,
    @Default(false) bool isFirstTimeBuyer,
    @Default(false) bool isVerified,
    String? ghanaidUrl,
    @Default(false) bool ghanaidVerified,
    DateTime? ghanaidVerifiedAt,
    @Default('GHS') String preferredCurrency,
    @Default('en') String preferredLanguage,
    @Default('') String referralCode,
    String? pushToken,
    Map<String, dynamic>? notificationPreferences,
    DateTime? lastActiveAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return UserModel(id: doc.id, fullName: '', phone: '', role: 'buyer');
    }
    return UserModel(
      id: doc.id,
      fullName: data['fullName'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String?,
      role: data['role'] as String? ?? 'buyer',
      location: data['location'] as String?,
      isFirstTimeBuyer: data['isFirstTimeBuyer'] as bool? ?? false,
      isVerified: data['isVerified'] as bool? ?? false,
      ghanaidUrl: data['ghanaidUrl'] as String?,
      ghanaidVerified: data['ghanaidVerified'] as bool? ?? false,
      ghanaidVerifiedAt:
          (data['ghanaidVerifiedAt'] as Timestamp?)?.toDate(),
      preferredCurrency:
          data['preferredCurrency'] as String? ?? 'GHS',
      preferredLanguage:
          data['preferredLanguage'] as String? ?? 'en',
      referralCode: data['referralCode'] as String? ?? '',
      pushToken: data['pushToken'] as String?,
      notificationPreferences:
          data['notificationPreferences'] as Map<String, dynamic>?,
      lastActiveAt:
          (data['lastActiveAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}

extension UserModelX on UserModel {
  String get firstName =>
      fullName.trim().isEmpty ? '' : fullName.split(' ').first;

  bool get notifNewOrderAssigned =>
      notificationPreferences?['newOrderAssigned'] as bool? ?? true;
  bool get notifBuyerMessages =>
      notificationPreferences?['buyerMessages'] as bool? ?? true;
  bool get notifPaymentConfirmations =>
      notificationPreferences?['paymentConfirmations'] as bool? ?? true;
  bool get notifInactivityReminders =>
      notificationPreferences?['inactivityReminders'] as bool? ?? true;
  bool get notifAuctionDeadlineAlerts =>
      notificationPreferences?['auctionDeadlineAlerts'] as bool? ?? true;
  bool get notifAgentMessages =>
      notificationPreferences?['agentMessages'] as bool? ?? true;
  bool get notifOrderUpdates =>
      notificationPreferences?['orderUpdates'] as bool? ?? true;
  bool get notifPaymentRequests =>
      notificationPreferences?['paymentRequests'] as bool? ?? true;

  /// Maps Firestore user document to the customer app domain user.
  AppUser toAppUser() {
    final prefs = notificationPreferences;
    var agentMessages = true;
    var orderUpdates = true;
    var paymentRequests = true;
    var promotionsAndNews = false;
    if (prefs != null) {
      agentMessages = prefs['agentMessages'] as bool? ?? true;
      orderUpdates = prefs['orderUpdates'] as bool? ?? true;
      paymentRequests = prefs['paymentRequests'] as bool? ?? true;
      promotionsAndNews = prefs['promotionsAndNews'] as bool? ?? false;
    }
    return AppUser(
      id: id,
      fullName: fullName,
      phone: phone,
      email: email,
      role: role,
      location: location ?? '',
      isFirstTimeBuyer: isFirstTimeBuyer,
      isVerified: isVerified,
      ghanaidUrl: ghanaidUrl,
      ghanaidVerified: ghanaidVerified,
      ghanaidVerifiedAt: ghanaidVerifiedAt,
      preferredCurrency: preferredCurrency,
      preferredLanguage: preferredLanguage,
      referralCode: referralCode,
      notificationPreferences: {
        'agentMessages': agentMessages,
        'orderUpdates': orderUpdates,
        'paymentRequests': paymentRequests,
        'promotionsAndNews': promotionsAndNews,
      },
    );
  }
}
