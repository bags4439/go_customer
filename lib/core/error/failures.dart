abstract class Failure {
  final String message;
  final Object? cause;

  const Failure({required this.message, this.cause});
}

class FirestoreFailure extends Failure {
  const FirestoreFailure({required super.message, super.cause});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.cause});
}

class FirebaseAuthFailure extends Failure {
  const FirebaseAuthFailure({required super.message, super.cause});
}

class StorageFailure extends Failure {
  const StorageFailure({required super.message, super.cause});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.cause});
}

class PaymentFailure extends Failure {
  const PaymentFailure({required super.message, super.cause});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.cause});
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message, super.cause});
}

