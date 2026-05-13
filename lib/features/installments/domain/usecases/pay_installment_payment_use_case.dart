// lib/features/installments/domain/usecases/pay_installment_payment_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/payment_entity.dart';
import '../repositories/installment_repository.dart';

class PayInstallmentPaymentParams {
  const PayInstallmentPaymentParams({
    required this.payment,
    required this.now,
  });

  final PaymentEntity payment;
  final DateTime now;
}

class PayInstallmentPaymentUseCase {
  PayInstallmentPaymentUseCase(this._repository);

  final InstallmentRepository _repository;

  Future<Either<Failure, void>> call(PayInstallmentPaymentParams params) =>
      _repository.payInstallmentPayment(params.payment, params.now);
}
