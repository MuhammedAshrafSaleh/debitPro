// lib/features/installments/domain/usecases/delete_installment_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/installment_repository.dart';

class DeleteInstallmentUseCase {
  DeleteInstallmentUseCase(this._repository);

  final InstallmentRepository _repository;

  Future<Either<Failure, void>> call(String installmentId) =>
      _repository.deleteInstallment(installmentId);
}
