// lib/features/grace_periods/domain/usecases/edit_grace_period_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/grace_period_entity.dart';
import '../repositories/grace_period_repository.dart';

class EditGracePeriodUseCase {
  EditGracePeriodUseCase(this._repository);

  final GracePeriodRepository _repository;

  Future<Either<Failure, GracePeriodEntity>> call(
    EditGracePeriodParams params,
  ) async {
    try {
      return await _repository.editGracePeriod(params);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
