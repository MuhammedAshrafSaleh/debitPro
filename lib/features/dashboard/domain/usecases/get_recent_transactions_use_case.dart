// lib/features/dashboard/domain/usecases/get_recent_transactions_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../payments/domain/entities/transaction_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetRecentTransactionsUseCase {
  GetRecentTransactionsUseCase(this._repository);

  final DashboardRepository _repository;

  Future<Either<Failure, List<TransactionEntity>>> call({int limit = 10}) {
    return _repository.getRecentTransactions(limit);
  }
}
