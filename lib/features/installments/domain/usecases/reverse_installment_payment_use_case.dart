// lib/features/installments/domain/usecases/reverse_installment_payment_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/payment_entity.dart';
import '../repositories/installment_repository.dart';

class ReverseInstallmentPaymentUseCase {
  ReverseInstallmentPaymentUseCase(this._repository);

  final InstallmentRepository _repository;

  Future<Either<Failure, void>> call(PaymentEntity payment) =>
      _repository.reverseInstallmentPayment(payment);
}
