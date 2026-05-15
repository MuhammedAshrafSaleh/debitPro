// lib/features/payments/domain/usecases/watch_transactions_for_client_use_case.dart

import '../entities/transaction_entity.dart';
import '../repositories/payment_repository.dart';

class WatchTransactionsForClientUseCase {
  WatchTransactionsForClientUseCase(this._repository);

  final PaymentRepository _repository;

  Stream<List<TransactionEntity>> call(String clientId) =>
      _repository.watchTransactionsForClient(clientId);
}
