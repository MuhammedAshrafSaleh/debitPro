// lib/features/clients/domain/usecases/delete_client_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/client_repository.dart';

class DeleteClientUseCase {
  DeleteClientUseCase(this._repository);

  final ClientRepository _repository;

  Future<Either<Failure, void>> call(String id) async {
    try {
      return await _repository.deleteClient(id);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }
}
