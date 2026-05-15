// lib/features/accounts/data/repositories/accounts_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/accounts_filter.dart';
import '../../domain/entities/pdf_transaction_row.dart';
import '../../domain/repositories/accounts_repository.dart';
import '../datasources/firestore_accounts_datasource.dart';

class AccountsRepositoryImpl implements AccountsRepository {
  AccountsRepositoryImpl(this._dataSource, this._networkInfo);

  final AccountsRemoteDataSource _dataSource;
  final NetworkInfo _networkInfo;
  final _log = Logger();

  @override
  Future<Either<Failure, AccountsRawData>> fetchAccountsData(
    AccountsFilter filter,
  ) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      final data = await _dataSource.fetchAccountsData(filter);
      return Right(data);
    } on ServerException catch (e) {
      _log.e('fetchAccountsData', error: e);
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, List<PdfTransactionRow>>> fetchTransactionsPdf(
    AccountsFilter filter,
  ) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      final rows = await _dataSource.fetchTransactionsPdf(filter);
      return Right(rows);
    } on ServerException catch (e) {
      _log.e('fetchTransactionsPdf', error: e);
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }
}
