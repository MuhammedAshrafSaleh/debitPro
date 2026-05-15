// lib/features/payments/data/repositories/payment_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/firestore_payment_datasource.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl(this._dataSource, this._networkInfo);

  final PaymentRemoteDataSource _dataSource;
  final NetworkInfo _networkInfo;
  final _log = Logger();

  Future<Either<Failure, T>?> _checkNetwork<T>() async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    return null;
  }

  @override
  Future<Either<Failure, void>> payInstallmentPayment(
    PayInstallmentPaymentParams params,
  ) async {
    final offline = await _checkNetwork<void>();
    if (offline != null) return offline;
    try {
      await _dataSource.payInstallmentPayment(params);
      return const Right(null);
    } on AlreadyPaidException catch (e) {
      return Left(AlreadyPaidFailure(e.message));
    } on ServerException catch (e) {
      _log.e('payInstallmentPayment', error: e);
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, void>> payGracePeriod(
    PayGracePeriodParams params,
  ) async {
    final offline = await _checkNetwork<void>();
    if (offline != null) return offline;
    try {
      await _dataSource.payGracePeriod(params);
      return const Right(null);
    } on AlreadyPaidException catch (e) {
      return Left(AlreadyPaidFailure(e.message));
    } on ServerException catch (e) {
      _log.e('payGracePeriod', error: e);
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, void>> reversePayment(
    ReversePaymentParams params,
  ) async {
    final offline = await _checkNetwork<void>();
    if (offline != null) return offline;
    try {
      await _dataSource.reversePayment(params);
      return const Right(null);
    } on ServerException catch (e) {
      _log.e('reversePayment', error: e);
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Stream<List<TransactionEntity>> watchTransactionsForClient(String clientId) {
    return _dataSource.watchTransactionsForClient(clientId);
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions(
    TransactionsFilter filter,
  ) async {
    final offline = await _checkNetwork<List<TransactionEntity>>();
    if (offline != null) return offline;
    try {
      final result = await _dataSource.getTransactions(filter);
      return Right(result);
    } on ServerException catch (e) {
      _log.e('getTransactions', error: e);
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }
}
