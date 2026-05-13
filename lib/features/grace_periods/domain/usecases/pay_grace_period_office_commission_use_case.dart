// lib/features/grace_periods/domain/usecases/pay_grace_period_office_commission_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/grace_period_repository.dart';

class PayGracePeriodOfficeCommissionUseCase {
  PayGracePeriodOfficeCommissionUseCase(this._repository);

  final GracePeriodRepository _repository;

  Future<Either<Failure, void>> call(String gracePeriodId) async {
    try {
      return await _repository.payOfficeCommission(gracePeriodId);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
