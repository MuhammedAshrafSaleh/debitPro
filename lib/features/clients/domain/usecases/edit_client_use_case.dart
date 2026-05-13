// lib/features/clients/domain/usecases/edit_client_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/client_entity.dart';
import '../../domain/repositories/client_repository.dart';

class EditClientUseCase {
  EditClientUseCase(this._repository);

  final ClientRepository _repository;

  Future<Either<Failure, ClientEntity>> call(EditClientParams params) async {
    if (params.fullName.trim().isEmpty) {
      return Left(ValidationFailure('اسم العميل مطلوب'));
    }
    if (params.phone.trim().isEmpty) {
      return Left(ValidationFailure('رقم الهاتف مطلوب'));
    }
    try {
      return await _repository.editClient(params);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }
}
