class AppUser {
  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final String? smsPhone;
  final String? whatsappPhone;
  final String role;
  final String location;
  /// ISO 3166-1 alpha-2 e.g. 'GH'; empty if unset.
  final String country;
  final bool isFirstTimeBuyer;
  final bool isVerified;
  final String? ghanaCardPhotoUrl;
  final String? ghanaCardNumber;
  /// Type of identity document provided.
  /// 'ghana_card' | 'passport' | '' (not set)
  final String idDocumentType;
  final String preferredCurrency;
  final String preferredLanguage;
  final Map<String, bool> notificationPreferences;
  final String referralCode;

  /// Explicit wizard completion flag. `null` = legacy account (grandfathered).
  final bool? registrationComplete;

  /// Resume point when [registrationComplete] is false.
  final String? registrationWizardStep;

  const AppUser({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    this.smsPhone,
    this.whatsappPhone,
    required this.role,
    required this.location,
    this.country = '',
    required this.isFirstTimeBuyer,
    required this.isVerified,
    this.ghanaCardPhotoUrl,
    this.ghanaCardNumber,
    this.idDocumentType = '',
    this.preferredCurrency = 'GHS',
    this.preferredLanguage = 'en',
    this.referralCode = '',
    this.registrationComplete,
    this.registrationWizardStep,
    Map<String, bool>? notificationPreferences,
  }) : notificationPreferences =
           notificationPreferences ??
           const {
             'agentMessages': true,
             'orderUpdates': true,
             'paymentRequests': true,
             'promotionsAndNews': false,
           };

  /// True if the user has provided any identity document.
  bool get hasIdDocument =>
      (ghanaCardPhotoUrl != null && ghanaCardPhotoUrl!.isNotEmpty) ||
      (ghanaCardNumber != null && ghanaCardNumber!.isNotEmpty);

  /// Alias for [hasIdDocument] (backward compatibility).
  bool get hasGhanaCard => hasIdDocument;

  /// Returns true if user is Ghanaian.
  bool get isGhanaian => country == 'GH';

  /// The correct document type label for this user based on their country.
  String get idDocumentLabel => isGhanaian ? 'Ghana Card' : 'Passport';

  /// The correct number label for this user.
  String get idNumberLabel =>
      isGhanaian ? 'Ghana Card number' : 'Passport number';

  /// The correct number hint for this user.
  String get idNumberHint => isGhanaian ? 'GHA-XXXXXXXXX-X' : 'A12345678';

  /// The resolved document type for saving.
  String get resolvedDocumentType =>
      isGhanaian ? 'ghana_card' : 'passport';
}

class PhoneVerificationSession {
  final String verificationId;
  final int? resendToken;
  final DateTime expiresAt;

  const PhoneVerificationSession({
    required this.verificationId,
    required this.resendToken,
    required this.expiresAt,
  });
}
