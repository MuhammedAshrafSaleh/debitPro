// lib/features/clients/domain/usecases/delete_client_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/client_repository.dart';

class DeleteClientParams {
  const DeleteClientParams({
    required this.id,
    required this.totalDuePaymentsCount,
  });

  final String id;
  final int totalDuePaymentsCount;
}

class DeleteClientUseCase {
  DeleteClientUseCase(this._repository);

  final ClientRepository _repository;

  Future<Either<Failure, void>> call(DeleteClientParams params) async {
    if (params.totalDuePaymentsCount > 0) {
      return const Left(
        ValidationFailure('لا يمكن حذف العميل لأن لديه دفعات مسجلة'),
      );
    }
    try {
      return await _repository.deleteClient(params.id);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }
}
