// lib/features/grace_periods/domain/usecases/watch_grace_periods_for_client_use_case.dart

import '../entities/grace_period_entity.dart';
import '../repositories/grace_period_repository.dart';

class WatchGracePeriodsForClientUseCase {
  WatchGracePeriodsForClientUseCase(this._repository);

  final GracePeriodRepository _repository;

  Stream<List<GracePeriodEntity>> call(String clientId) {
    return _repository.watchGracePeriodsForClient(clientId);
  }
}
