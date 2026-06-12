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
    String? smsPhone,
    String? whatsappPhone,
    required String role, // 'buyer' | 'agent' | 'admin'
    String? location,
    @Default('') String country,
    @Default(false) bool isFirstTimeBuyer,
    @Default(false) bool isVerified,
    String? ghanaCardPhotoUrl,
    String? ghanaCardNumber,
    @Default('') String idDocumentType,
    @Default('GHS') String preferredCurrency,
    @Default('en') String preferredLanguage,
    @Default('') String referralCode,
    bool? registrationComplete,
    String? registrationWizardStep,
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
      return UserModel(
        id: doc.id,
        fullName: '',
        phone: '',
        role: 'buyer',
        country: '',
      );
    }
    return UserModel(
      id: doc.id,
      fullName: data['fullName'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String?,
      smsPhone: data['smsPhone'] as String?,
      whatsappPhone: data['whatsappPhone'] as String?,
      role: data['role'] as String? ?? 'buyer',
      location: data['location'] as String?,
      country: data['country'] as String? ?? '',
      isFirstTimeBuyer: data['isFirstTimeBuyer'] as bool? ?? false,
      isVerified: data['isVerified'] as bool? ?? false,
      ghanaCardPhotoUrl:
          data['ghanaCardPhotoUrl'] as String? ?? data['ghanaidUrl'] as String?,
      ghanaCardNumber: data['ghanaCardNumber'] as String?,
      idDocumentType: data['idDocumentType'] as String? ?? '',
      preferredCurrency: data['preferredCurrency'] as String? ?? 'GHS',
      preferredLanguage: data['preferredLanguage'] as String? ?? 'en',
      referralCode: data['referralCode'] as String? ?? '',
      registrationComplete: data['registrationComplete'] as bool?,
      registrationWizardStep: data['registrationWizardStep'] as String?,
      pushToken: data['pushToken'] as String?,
      notificationPreferences:
          data['notificationPreferences'] as Map<String, dynamic>?,
      lastActiveAt: (data['lastActiveAt'] as Timestamp?)?.toDate(),
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
      smsPhone: smsPhone,
      whatsappPhone: whatsappPhone,
      role: role,
      location: location ?? '',
      country: country,
      isFirstTimeBuyer: isFirstTimeBuyer,
      isVerified: isVerified,
      ghanaCardPhotoUrl: ghanaCardPhotoUrl,
      ghanaCardNumber: ghanaCardNumber,
      idDocumentType: idDocumentType,
      preferredCurrency: preferredCurrency,
      preferredLanguage: preferredLanguage,
      referralCode: referralCode,
      registrationComplete: registrationComplete,
      registrationWizardStep: registrationWizardStep,
      notificationPreferences: {
        'agentMessages': agentMessages,
        'orderUpdates': orderUpdates,
        'paymentRequests': paymentRequests,
        'promotionsAndNews': promotionsAndNews,
      },
    );
  }
}
