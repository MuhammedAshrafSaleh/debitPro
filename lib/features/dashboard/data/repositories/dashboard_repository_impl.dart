// lib/features/dashboard/data/repositories/dashboard_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../payments/data/models/transaction_model.dart';
import '../../../payments/domain/entities/transaction_entity.dart';
import '../../domain/entities/dashboard_data.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/firestore_dashboard_datasource.dart';
import '../models/dashboard_aggregates.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._dataSource, this._networkInfo);

  final DashboardRemoteDataSource _dataSource;
  final NetworkInfo _networkInfo;
  final _log = Logger();

  Future<Either<Failure, T>?> _checkNetwork<T>() async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    return null;
  }

  @override
  Future<Either<Failure, DashboardData>> getDashboardData(DateTime now) async {
    final offline = await _checkNetwork<DashboardData>();
    if (offline != null) return offline;
    try {
      final aggregatesFuture = _dataSource.fetchAggregates(now);
      final recentFuture = _dataSource.fetchRecentTransactions(10);
      final aggregates = await aggregatesFuture;
      final recent = await recentFuture;
      final clientIds = recent.map((t) => t.clientId).toSet().toList();
      final names = await _dataSource.fetchClientNames(clientIds);
      return Right(_build(aggregates, recent, names));
    } on ServerException catch (e) {
      _log.e('getDashboardData', error: e);
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getRecentTransactions(
    int limit,
  ) async {
    final offline = await _checkNetwork<List<TransactionEntity>>();
    if (offline != null) return offline;
    try {
      final list = await _dataSource.fetchRecentTransactions(limit);
      return Right(list);
    } on ServerException catch (e) {
      _log.e('getRecentTransactions', error: e);
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }

  DashboardData _build(
    DashboardAggregates aggregates,
    List<TransactionModel> recent,
    Map<String, String> names,
  ) {
    return DashboardData(
      monthlyCollection: aggregates.monthlyCollection,
      monthlyTarget: aggregates.monthlyTarget,
      totalProfits: aggregates.totalProfits,
      totalCapital: aggregates.totalCapital,
      totalOfficeCommission: aggregates.totalOfficeCommission,
      totalClients: aggregates.totalClients,
      recentTransactions: recent,
      clientNamesById: names,
    );
  }
}
