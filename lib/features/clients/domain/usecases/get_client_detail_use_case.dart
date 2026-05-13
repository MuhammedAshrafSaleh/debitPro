// lib/features/clients/domain/usecases/get_client_detail_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/client_entity.dart';
import '../../domain/repositories/client_repository.dart';

class GetClientDetailUseCase {
  GetClientDetailUseCase(this._repository);

  final ClientRepository _repository;

  Future<Either<Failure, ClientEntity>> call(String id) async {
    try {
      return await _repository.getClient(id);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }
}
