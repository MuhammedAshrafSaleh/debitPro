// lib/features/installments/domain/usecases/edit_installment_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../entities/installment_entity.dart';
import '../repositories/installment_repository.dart';

class EditInstallmentUseCase {
  EditInstallmentUseCase(this._repository);

  final InstallmentRepository _repository;

  Future<Either<Failure, InstallmentEntity>> call(
    EditInstallmentParams params,
  ) async {
    if (params.itemName.trim().isEmpty) {
      return Left(ValidationFailure('اسم السلعة مطلوب'));
    }
    if (params.capital <= 0) {
      return Left(ValidationFailure('رأس المال يجب أن يكون أكبر من صفر'));
    }
    if (params.profitAmount < 0) {
      return Left(ValidationFailure('الربح لا يمكن أن يكون سالباً'));
    }
    if (!AppConstants.kAllowedDurationMonths.contains(params.durationMonths)) {
      return Left(
        ValidationFailure('المدة يجب أن تكون: ${AppConstants.kAllowedDurationMonths.join(', ')} شهر'),
      );
    }
    try {
      return await _repository.editInstallment(params);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }
}
