// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      smsPhone: json['smsPhone'] as String?,
      whatsappPhone: json['whatsappPhone'] as String?,
      role: json['role'] as String,
      location: json['location'] as String?,
      country: json['country'] as String? ?? '',
      isFirstTimeBuyer: json['isFirstTimeBuyer'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      ghanaCardPhotoUrl: json['ghanaCardPhotoUrl'] as String?,
      ghanaCardNumber: json['ghanaCardNumber'] as String?,
      idDocumentType: json['idDocumentType'] as String? ?? '',
      preferredCurrency: json['preferredCurrency'] as String? ?? 'GHS',
      preferredLanguage: json['preferredLanguage'] as String? ?? 'en',
      referralCode: json['referralCode'] as String? ?? '',
      registrationComplete: json['registrationComplete'] as bool?,
      registrationWizardStep: json['registrationWizardStep'] as String?,
      pushToken: json['pushToken'] as String?,
      notificationPreferences:
          json['notificationPreferences'] as Map<String, dynamic>?,
      lastActiveAt: json['lastActiveAt'] == null
          ? null
          : DateTime.parse(json['lastActiveAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'phone': instance.phone,
      'email': instance.email,
      'smsPhone': instance.smsPhone,
      'whatsappPhone': instance.whatsappPhone,
      'role': instance.role,
      'location': instance.location,
      'country': instance.country,
      'isFirstTimeBuyer': instance.isFirstTimeBuyer,
      'isVerified': instance.isVerified,
      'ghanaCardPhotoUrl': instance.ghanaCardPhotoUrl,
      'ghanaCardNumber': instance.ghanaCardNumber,
      'idDocumentType': instance.idDocumentType,
      'preferredCurrency': instance.preferredCurrency,
      'preferredLanguage': instance.preferredLanguage,
      'referralCode': instance.referralCode,
      'registrationComplete': instance.registrationComplete,
      'registrationWizardStep': instance.registrationWizardStep,
      'pushToken': instance.pushToken,
      'notificationPreferences': instance.notificationPreferences,
      'lastActiveAt': instance.lastActiveAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
