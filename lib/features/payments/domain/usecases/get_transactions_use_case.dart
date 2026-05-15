// lib/features/payments/domain/usecases/get_transactions_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/transaction_entity.dart';
import '../repositories/payment_repository.dart';

class GetTransactionsUseCase {
  GetTransactionsUseCase(this._repository);

  final PaymentRepository _repository;

  Future<Either<Failure, List<TransactionEntity>>> call(
    TransactionsFilter filter,
  ) =>
      _repository.getTransactions(filter);
}
