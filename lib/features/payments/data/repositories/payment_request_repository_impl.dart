import '../../domain/entities/payment_request.dart';
import '../../domain/repositories/payment_request_repository.dart';
import '../datasources/payment_firestore_data_source.dart';

class PaymentRequestRepositoryImpl implements PaymentRequestRepository {
  final PaymentFirestoreDataSource _dataSource;

  PaymentRequestRepositoryImpl(this._dataSource);

  @override
  Stream<PaymentRequest?> watchPaymentRequest(String requestId) {
    return _dataSource.watchPaymentRequest(requestId);
  }
}
