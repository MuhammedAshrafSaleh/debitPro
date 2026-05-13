// lib/features/installments/domain/usecases/pay_office_commission_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/installment_repository.dart';

class PayOfficeCommissionUseCase {
  PayOfficeCommissionUseCase(this._repository);

  final InstallmentRepository _repository;

  Future<Either<Failure, void>> call(String installmentId) async {
    try {
      return await _repository.payOfficeCommission(installmentId);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }
}
