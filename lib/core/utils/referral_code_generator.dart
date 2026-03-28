import 'dart:math';

/// Generates random 6-character referral codes.
/// Uses a safe charset that excludes visually
/// ambiguous characters (0, 1, I, O).
class ReferralCodeGenerator {
  static const _charset =
      '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
  static const _length = 6;

  ReferralCodeGenerator._();

  static String generate() {
    final random = Random.secure();
    return List.generate(
      _length,
      (_) => _charset[random.nextInt(_charset.length)],
    ).join();
  }
}
