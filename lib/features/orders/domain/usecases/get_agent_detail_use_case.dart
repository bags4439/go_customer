import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/agent_detail_view.dart';
import '../repositories/order_repository.dart';

class GetAgentDetailUseCase {
  final OrderRepository _repository;
  const GetAgentDetailUseCase(this._repository);

  Future<Either<Failure, AgentDetailView?>> call(String agentId) =>
      _repository.getAgentDetail(agentId);
}
