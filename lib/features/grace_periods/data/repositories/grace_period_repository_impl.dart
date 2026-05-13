// lib/features/grace_periods/data/repositories/grace_period_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/grace_period_entity.dart';
import '../../domain/repositories/grace_period_repository.dart';
import '../datasources/firestore_grace_period_datasource.dart';

class GracePeriodRepositoryImpl implements GracePeriodRepository {
  GracePeriodRepositoryImpl(this._dataSource, this._networkInfo);

  final GracePeriodRemoteDataSource _dataSource;
  final NetworkInfo _networkInfo;
  final _log = Logger();

  Future<Either<Failure, T>?> _checkNetwork<T>() async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    return null;
  }

  @override
  Stream<List<GracePeriodEntity>> watchGracePeriodsForClient(String clientId) {
    return _dataSource.watchGracePeriodsForClient(clientId);
  }

  @override
  Future<Either<Failure, GracePeriodEntity>> getGracePeriod(
    String gracePeriodId,
  ) async {
    final offline = await _checkNetwork<GracePeriodEntity>();
    if (offline != null) return offline;
    try {
      final result = await _dataSource.getGracePeriod(gracePeriodId);
      return Right(result);
    } on ServerException catch (e) {
      _log.e('getGracePeriod', error: e);
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, GracePeriodEntity>> addGracePeriod(
    AddGracePeriodParams params,
  ) async {
    final offline = await _checkNetwork<GracePeriodEntity>();
    if (offline != null) return offline;
    try {
      final result = await _dataSource.addGracePeriod(params);
      return Right(result);
    } on ServerException catch (e) {
      _log.e('addGracePeriod', error: e);
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, GracePeriodEntity>> editGracePeriod(
    EditGracePeriodParams params,
  ) async {
    final offline = await _checkNetwork<GracePeriodEntity>();
    if (offline != null) return offline;

    // 9.5 — block edit if locked
    try {
      final existing = await _dataSource.getGracePeriod(params.id);
      if (existing.editLocked) {
        return const Left(EditLockedFailure());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }

    try {
      final result = await _dataSource.editGracePeriod(params);
      return Right(result);
    } on ServerException catch (e) {
      _log.e('editGracePeriod', error: e);
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, void>> payOfficeCommission(
    String gracePeriodId,
  ) async {
    final offline = await _checkNetwork<void>();
    if (offline != null) return offline;
    try {
      await _dataSource.payOfficeCommission(gracePeriodId);
      return const Right(null);
    } on ServerException catch (e) {
      _log.e('payOfficeCommission', error: e);
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, void>> payGracePeriod(String gracePeriodId) async {
    final offline = await _checkNetwork<void>();
    if (offline != null) return offline;
    try {
      await _dataSource.payGracePeriod(gracePeriodId);
      return const Right(null);
    } on ServerException catch (e) {
      _log.e('payGracePeriod', error: e);
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }
}
