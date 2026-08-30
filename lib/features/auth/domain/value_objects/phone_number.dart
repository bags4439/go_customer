import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

/// Validated international phone
/// number in E.164 format.
/// Immutable value object —
/// created via factory methods.
class PhoneNumber {
  /// Always E.164 e.g. +233XXXXXXXXX
  final String value;
  const PhoneNumber._(this.value);

  /// Creates from a dial code and
  /// raw digit string.
  ///
  /// [dialCode] e.g. '+233', '+1'
  /// [digits]   local digits only,
  ///            no leading zeros,
  ///            no spaces
  ///
  /// Validates:
  ///   - dialCode starts with '+'
  ///   - digits is non-empty
  ///   - combined length is
  ///     reasonable (7-15 digits
  ///     per ITU E.164)
  static Either<ValidationFailure, PhoneNumber> fromDialCodeAndDigits({
    required String dialCode,
    required String digits,
  }) {
    final cleanDial = dialCode.trim();
    final enteredDigits = digits.trim().replaceAll(RegExp(r'\D'), '');

    if (!cleanDial.startsWith('+')) {
      return const Left(ValidationFailure(message: 'Invalid country code.'));
    }

    if (enteredDigits.isEmpty) {
      return const Left(
        ValidationFailure(
          message:
              'Please enter your '
              'phone number.',
        ),
      );
    }

    final dialDigits = cleanDial.replaceAll(RegExp(r'\D'), '');
    // Ghanaian users commonly enter local numbers with the national trunk
    // prefix (for example 027...). E.164 omits that zero after +233.
    final cleanDigits = cleanDial == '+233' && enteredDigits.startsWith('0')
        ? enteredDigits.substring(1)
        : enteredDigits;
    final totalDigits = dialDigits.length + cleanDigits.length;

    if (totalDigits < 7 || totalDigits > 15) {
      return const Left(
        ValidationFailure(
          message:
              'Please enter a valid '
              'phone number.',
        ),
      );
    }

    final e164 = '$cleanDial$cleanDigits';
    return Right(PhoneNumber._(e164));
  }

  /// Creates from a full E.164
  /// string directly.
  /// Used for backward compatibility
  /// where the full number is
  /// already known.
  static Either<ValidationFailure, PhoneNumber> fromE164(String raw) {
    final trimmed = raw.trim();
    if (!trimmed.startsWith('+')) {
      return const Left(
        ValidationFailure(
          message:
              'Please enter a valid '
              'phone number.',
        ),
      );
    }
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7 || digits.length > 15) {
      return const Left(
        ValidationFailure(
          message:
              'Please enter a valid '
              'phone number.',
        ),
      );
    }
    return Right(PhoneNumber._(trimmed));
  }

  @override
  bool operator ==(Object other) =>
      other is PhoneNumber && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
