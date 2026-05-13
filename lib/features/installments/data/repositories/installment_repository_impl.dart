// lib/features/installments/data/repositories/installment_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/installment_entity.dart';
import '../../domain/repositories/installment_repository.dart';
import '../datasources/firestore_installment_datasource.dart';

class InstallmentRepositoryImpl implements InstallmentRepository {
  InstallmentRepositoryImpl(this._dataSource, this._networkInfo);

  final InstallmentRemoteDataSource _dataSource;
  final NetworkInfo _networkInfo;
  final _log = Logger();

  Future<Either<Failure, T>?> _checkNetwork<T>() async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    return null;
  }

  @override
  Stream<List<InstallmentEntity>> watchInstallmentsForClient(String clientId) {
    return _dataSource.watchInstallmentsForClient(clientId);
  }

  @override
  Future<Either<Failure, InstallmentWithPayments>> getInstallmentWithPayments(
    String installmentId,
  ) async {
    final offline = await _checkNetwork<InstallmentWithPayments>();
    if (offline != null) return offline;
    try {
      final (installment, payments) =
          await _dataSource.getInstallmentWithPayments(installmentId);
      return Right(InstallmentWithPayments(
        installment: installment,
        payments: payments,
      ));
    } on ServerException catch (e) {
      _log.e('getInstallmentWithPayments', error: e);
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, InstallmentEntity>> addInstallment(
    AddInstallmentParams params,
  ) async {
    final offline = await _checkNetwork<InstallmentEntity>();
    if (offline != null) return offline;
    try {
      final result = await _dataSource.addInstallment(params);
      return Right(result);
    } on ServerException catch (e) {
      _log.e('addInstallment', error: e);
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, InstallmentEntity>> editInstallment(
    EditInstallmentParams params,
  ) async {
    final offline = await _checkNetwork<InstallmentEntity>();
    if (offline != null) return offline;

    // 8.5 — check editLocked before dispatching to datasource
    try {
      final (existing, _) =
          await _dataSource.getInstallmentWithPayments(params.id);
      if (existing.editLocked) {
        return const Left(EditLockedFailure());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }

    try {
      final result = await _dataSource.editInstallment(params);
      return Right(result);
    } on ServerException catch (e) {
      _log.e('editInstallment', error: e);
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, void>> payOfficeCommission(
    String installmentId,
  ) async {
    final offline = await _checkNetwork<void>();
    if (offline != null) return offline;
    try {
      await _dataSource.payOfficeCommission(installmentId);
      return const Right(null);
    } on ServerException catch (e) {
      _log.e('payOfficeCommission', error: e);
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }
}
