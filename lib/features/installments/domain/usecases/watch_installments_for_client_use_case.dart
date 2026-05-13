// lib/features/installments/domain/usecases/watch_installments_for_client_use_case.dart

import '../entities/installment_entity.dart';
import '../repositories/installment_repository.dart';

class WatchInstallmentsForClientUseCase {
  WatchInstallmentsForClientUseCase(this._repository);

  final InstallmentRepository _repository;

  Stream<List<InstallmentEntity>> call(String clientId) =>
      _repository.watchInstallmentsForClient(clientId);
}
