// lib/features/payments/domain/usecases/reverse_payment_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/payment_repository.dart';

class ReversePaymentUseCase {
  ReversePaymentUseCase(this._repository);

  final PaymentRepository _repository;

  Future<Either<Failure, void>> call(ReversePaymentParams params) =>
      _repository.reversePayment(params);
}
