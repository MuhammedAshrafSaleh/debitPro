// lib/features/dashboard/domain/repositories/dashboard_repository.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../payments/domain/entities/transaction_entity.dart';
import '../entities/dashboard_data.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardData>> getDashboardData(DateTime now);
  Future<Either<Failure, List<TransactionEntity>>> getRecentTransactions(
    int limit,
  );
}
