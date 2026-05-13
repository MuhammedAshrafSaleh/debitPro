// lib/features/installments/domain/usecases/get_installment_with_payments_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/installment_repository.dart';

class GetInstallmentWithPaymentsUseCase {
  GetInstallmentWithPaymentsUseCase(this._repository);

  final InstallmentRepository _repository;

  Future<Either<Failure, InstallmentWithPayments>> call(
    String installmentId,
  ) async {
    try {
      return await _repository.getInstallmentWithPayments(installmentId);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }
}
