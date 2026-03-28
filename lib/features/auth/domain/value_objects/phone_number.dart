import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

/// Validated Ghanaian phone number in E.164 format.
/// Immutable value object — created via factory method.
class PhoneNumber {
  final String value; // always +233XXXXXXXXX
  const PhoneNumber._(this.value);

  /// Accepts any of these formats:
  ///   9 digits           → +233XXXXXXXXX
  ///   0XXXXXXXXX (10)    → +233XXXXXXXXX
  ///   233XXXXXXXXX (12)  → +233XXXXXXXXX
  ///   +233XXXXXXXXX      → +233XXXXXXXXX (normalized)
  static Either<ValidationFailure, PhoneNumber> create(
    String raw,
  ) {
    final trimmed = raw.trim();
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    late String e164;
    if (digits.length == 9) {
      e164 = '+233$digits';
    } else if (digits.length == 10 && digits.startsWith('0')) {
      e164 = '+233${digits.substring(1)}';
    } else if (digits.length == 12 && digits.startsWith('233')) {
      e164 = '+$digits';
    } else if (trimmed.startsWith('+233') &&
        digits.length == 12 &&
        digits.startsWith('233')) {
      e164 = '+$digits';
    } else {
      return const Left(
        ValidationFailure(
          message: 'Enter a valid Ghanaian phone number',
        ),
      );
    }
    return Right(PhoneNumber._(e164));
  }

  /// Local display format: 0XX XXX XXXX
  String get displayValue {
    final local = '0${value.substring(4)}';
    return '${local.substring(0, 3)} '
        '${local.substring(3, 6)} '
        '${local.substring(6)}';
  }

  @override
  bool operator ==(Object other) =>
      other is PhoneNumber && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
