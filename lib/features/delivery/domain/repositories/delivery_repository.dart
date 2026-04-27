import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../orders/data/models/buyer_review_model.dart';
import '../entities/delivery.dart';

abstract class DeliveryRepository {
  /// Watch the delivery document for an order.
  /// Returns null if no delivery document exists yet.
  Stream<Either<Failure, Delivery?>> watchDelivery(String orderId);

  /// Watch the buyer review for a given
  /// order. Returns null if not yet
  /// submitted.
  Stream<Either<Failure, BuyerReviewModel?>> watchReview({
    required String orderId,
    required String buyerId,
  });

  /// Save or update the delivery location.
  /// Creates the document if it doesn't exist.
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
  /// Sets buyerConfirmed=true and status='delivery_confirmed'.
  Future<Either<Failure, Unit>> confirmDelivery(String orderId);

  Future<Either<Failure, Unit>> confirmAgentDelivery(String orderId);

  Future<Either<Failure, Unit>> confirmSelfPickup(String orderId);

  Future<Either<Failure, Unit>> confirmSelfCollection(String orderId);

  /// Submit buyer review and close the order.
  /// Writes buyer_reviews document and sets
  /// orders.status='delivered'.
  Future<Either<Failure, Unit>> submitReviewAndClose({
    required String orderId,
    required String buyerId,
    required String agentId,
    required double overallRating,
    required double agentRating,
    required double communicationRating,
    required double speedRating,
    String? comment,
  });
}
