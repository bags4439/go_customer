import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../orders/data/models/buyer_review_model.dart';
import '../entities/delivery.dart';

abstract class DeliveryRepository {
  Stream<Either<Failure, Delivery?>> watchDelivery(String orderId);

  Stream<Either<Failure, BuyerReviewModel?>> watchReview({
    required String orderId,
    required String buyerId,
  });

  Future<Either<Failure, Unit>> saveDeliveryLocation({
    required String orderId,
    required String address,
    required String city,
    required String locationSource,
    double? latitude,
    double? longitude,
    String? locationLabel,
  });

  /// Buyer confirms they received their vehicle.
  Future<Either<Failure, Unit>> confirmDelivery(String orderId);

  Future<Either<Failure, Unit>> confirmAgentDelivery(String orderId);

  Future<Either<Failure, Unit>> confirmSelfPickup(String orderId);

  Future<Either<Failure, Unit>> confirmSelfCollection(String orderId);

  /// Submit buyer review and close the order.
  Future<Either<Failure, Unit>> submitReviewAndClose({
    required String orderId,
    required String buyerId,
    required String agentId,
    required double overallRating,
    String? comment,
  });
}
