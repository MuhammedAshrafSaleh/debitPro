// lib/features/payments/domain/usecases/pay_grace_period_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/payment_repository.dart';

class PayGracePeriodUseCase {
  PayGracePeriodUseCase(this._repository);

  final PaymentRepository _repository;

  Future<Either<Failure, void>> call(PayGracePeriodParams params) =>
      _repository.payGracePeriod(params);
}
