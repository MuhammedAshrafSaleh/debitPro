// lib/features/payments/domain/usecases/pay_installment_payment_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/payment_repository.dart';

class PayInstallmentPaymentUseCase {
  PayInstallmentPaymentUseCase(this._repository);

  final PaymentRepository _repository;

  Future<Either<Failure, void>> call(PayInstallmentPaymentParams params) =>
      _repository.payInstallmentPayment(params);
}
