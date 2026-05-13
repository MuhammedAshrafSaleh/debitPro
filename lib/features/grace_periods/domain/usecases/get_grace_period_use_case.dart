// lib/features/grace_periods/domain/usecases/get_grace_period_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/grace_period_entity.dart';
import '../repositories/grace_period_repository.dart';

class GetGracePeriodUseCase {
  GetGracePeriodUseCase(this._repository);

  final GracePeriodRepository _repository;

  Future<Either<Failure, GracePeriodEntity>> call(String gracePeriodId) async {
    try {
      return await _repository.getGracePeriod(gracePeriodId);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
