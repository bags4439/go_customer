class AppUser {
  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final String role;
  final String location;
  final bool isFirstTimeBuyer;
  final bool isVerified;
  final String? ghanaidUrl;
  final bool ghanaidVerified;
  final DateTime? ghanaidVerifiedAt;
  final String preferredCurrency;
  final String preferredLanguage;
  final Map<String, bool> notificationPreferences;
  final String referralCode;

  const AppUser({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.role,
    required this.location,
    required this.isFirstTimeBuyer,
    required this.isVerified,
    required this.ghanaidUrl,
    required this.ghanaidVerified,
    this.ghanaidVerifiedAt,
    this.preferredCurrency = 'GHS',
    this.preferredLanguage = 'en',
    this.referralCode = '',
    Map<String, bool>? notificationPreferences,
  }) : notificationPreferences = notificationPreferences ??
            const {
              'agentMessages': true,
              'orderUpdates': true,
              'paymentRequests': true,
              'promotionsAndNews': false,
            };
}

class RegisterUserParams {
  final String userId;
  final String fullName;
  final String phone;
  final String? email;
  final String location;
  final bool isFirstTimeBuyer;

  const RegisterUserParams({
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.location,
    required this.isFirstTimeBuyer,
  });
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

