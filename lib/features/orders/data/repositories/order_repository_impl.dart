import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/agent_detail_view.dart';
import '../../domain/entities/order_view.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_firestore_data_source.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderFirestoreDataSource _dataSource;
  final FirebaseFunctions _functions;

  const OrderRepositoryImpl(this._dataSource, this._functions);

  @override
  Stream<Either<Failure, OrderView?>> watchOrder(String orderId) {
    return _dataSource.watchOrder(orderId).map((raw) {
      try {
        if (raw.orderDoc == null) return const Right(null);
        return Right(_mapToOrderView(
          raw.orderId ?? orderId,
          raw.orderDoc!,
          raw.preferences,
        ));
      } catch (e) {
        return Left(
          UnexpectedFailure(message: e.toString(), cause: e),
        );
      }
    });
  }

  @override
  Stream<Either<Failure, List<OrderView>>> watchBuyerOrders(String buyerId) {
    return _dataSource.watchBuyerOrderIds(buyerId).asyncMap((ids) async {
      try {
        final futures =
            ids.map((id) => _dataSource.watchOrder(id).first);
        final raws = await Future.wait(futures);
        final views = raws
            .where((r) => r.orderDoc != null)
            .map(
              (r) => _mapToOrderView(
                r.orderId ?? '',
                r.orderDoc!,
                r.preferences,
              ),
            )
            .toList();

        views.sort((a, b) {
          if (a.needsPayment != b.needsPayment) {
            return a.needsPayment ? -1 : 1;
          }
          if (a.isCompleted != b.isCompleted) {
            return a.isCompleted ? 1 : -1;
          }
          final at = a.updatedAt ??
              a.createdAt ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final bt = b.updatedAt ??
              b.createdAt ??
              DateTime.fromMillisecondsSinceEpoch(0);
          return bt.compareTo(at);
        });

        return Right(views);
      } catch (e) {
        return Left(
          UnexpectedFailure(message: e.toString(), cause: e),
        );
      }
    });
  }

  @override
  Future<Either<Failure, AgentDetailView?>> getAgentDetail(
    String agentId,
  ) async {
    try {
      final raw = await _dataSource.getAgentDetail(agentId);
      if (raw == null) return const Right(null);
      return Right(_mapToAgentDetailView(raw));
    } on FirebaseException catch (e) {
      return Left(FirestoreFailure(
        message: e.message ?? 'Could not load agent.',
        cause: e,
      ));
    } catch (e) {
      return Left(
        UnexpectedFailure(message: e.toString(), cause: e),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>?>> getOrderGuard(
    String orderId,
  ) async {
    try {
      final data = await _dataSource.getOrderGuard(orderId);
      return right(data);
    } catch (e) {
      return left(
        FirestoreFailure(message: 'Could not load order.', cause: e),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> cancelOrder(String orderId) async {
    try {
      await _dataSource.cancelOrder(orderId);
      await _functions
          .httpsCallable('notifyAgentOrderCancelled')
          .call({'orderId': orderId});
      return right(unit);
    } catch (e) {
      return left(
        FirestoreFailure(message: 'Could not cancel order.', cause: e),
      );
    }
  }

  OrderView _mapToOrderView(
    String id,
    Map<String, dynamic> data,
    Map<String, dynamic>? prefs,
  ) {
    final status = data['status'] as String? ?? '';
    final createdRaw = data['createdAt'];
    final updatedRaw = data['updatedAt'];

    return OrderView(
      id: id,
      orderRef: data['orderRef'] as String? ?? id,
      agentId: data['agentId'] as String?,
      status: status,
      stageNumber: data['stageNumber'] as int? ?? 1,
      hasPendingPayment: status == FirestoreEnumValues.orderStatusPaymentPending,
      firstPaymentMade: data['firstPaymentMade'] as bool? ?? false,
      createdAt: createdRaw is Timestamp ? createdRaw.toDate() : null,
      updatedAt: updatedRaw is Timestamp ? updatedRaw.toDate() : null,
      make: prefs?['make'] as String?,
      model: prefs?['model'] as String?,
      trim: prefs?['trim'] as String?,
      purchaseOrigin: prefs?['purchaseOrigin'] as String? ?? 'any',
      isNewVehicle: prefs?['isNewVehicle'] as bool? ?? false,
      repairOptedIn: prefs?['repairOptedIn'] as bool? ?? false,
    );
  }

  AgentDetailView _mapToAgentDetailView(AgentRawData raw) {
    final fullName =
        raw.userData['fullName'] as String? ?? 'Assigned Agent';
    final intro = raw.agentData['agentIntroMessage'] as String? ??
        'Hi, I have received your request and I will '
            'start searching for options shortly.';

    return AgentDetailView(
      agentId: raw.agentId,
      userId: raw.userId,
      fullName: fullName,
      phone: raw.userData['phone'] as String?,
      photoUrl: raw.agentData['photoUrl'] as String?,
      successRate:
          (raw.agentData['successRate'] as num? ?? 98).toDouble(),
      rating: (raw.agentData['rating'] as num? ?? 4.9).toDouble(),
      totalOrdersCompleted:
          (raw.agentData['totalOrdersCompleted'] as num? ?? 0).toInt(),
      introMessage: intro,
    );
  }
}
