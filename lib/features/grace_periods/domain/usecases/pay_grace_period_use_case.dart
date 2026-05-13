// lib/features/grace_periods/domain/usecases/pay_grace_period_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/grace_period_repository.dart';

class PayGracePeriodUseCase {
  PayGracePeriodUseCase(this._repository);

  final GracePeriodRepository _repository;

  Future<Either<Failure, void>> call(String gracePeriodId) async {
    try {
      return await _repository.payGracePeriod(gracePeriodId);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
