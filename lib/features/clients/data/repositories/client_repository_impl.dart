// lib/features/clients/data/repositories/client_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/client_entity.dart';
import '../../domain/repositories/client_repository.dart';
import '../datasources/firestore_client_datasource.dart';

class ClientRepositoryImpl implements ClientRepository {
  ClientRepositoryImpl(this._dataSource, this._networkInfo);

  final ClientRemoteDataSource _dataSource;
  final NetworkInfo _networkInfo;
  final _log = Logger();

  Future<Either<Failure, T>?> _checkNetwork<T>() async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    return null;
  }

  @override
  Stream<List<ClientEntity>> watchClients(ClientFilter filter) {
    return _dataSource.watchClients(filter);
  }

  @override
  Future<Either<Failure, ClientEntity>> getClient(String id) async {
    final offline = await _checkNetwork<ClientEntity>();
    if (offline != null) return offline;
    try {
      final client = await _dataSource.getClient(id);
      return Right(client);
    } on ServerException catch (e) {
      _log.e('getClient', error: e);
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, ClientEntity>> addClient(AddClientParams params) async {
    final offline = await _checkNetwork<ClientEntity>();
    if (offline != null) return offline;
    try {
      final client = await _dataSource.addClient(params);
      return Right(client);
    } on ServerException catch (e) {
      _log.e('addClient', error: e);
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, ClientEntity>> editClient(EditClientParams params) async {
    final offline = await _checkNetwork<ClientEntity>();
    if (offline != null) return offline;
    try {
      final client = await _dataSource.editClient(params);
      return Right(client);
    } on ServerException catch (e) {
      _log.e('editClient', error: e);
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteClient(String id) async {
    final offline = await _checkNetwork<void>();
    if (offline != null) return offline;
    try {
      await _dataSource.deleteClient(id);
      return const Right(null);
    } on ServerException catch (e) {
      _log.e('deleteClient', error: e);
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }
}
