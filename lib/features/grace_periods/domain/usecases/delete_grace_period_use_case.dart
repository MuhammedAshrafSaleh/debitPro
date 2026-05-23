// lib/features/grace_periods/domain/usecases/delete_grace_period_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/grace_period_repository.dart';

class DeleteGracePeriodUseCase {
  DeleteGracePeriodUseCase(this._repository);

  final GracePeriodRepository _repository;

  Future<Either<Failure, void>> call(String gracePeriodId) =>
      _repository.deleteGracePeriod(gracePeriodId);
}
