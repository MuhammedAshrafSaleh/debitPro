// lib/features/payments/domain/repositories/payment_repository.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../grace_periods/domain/entities/grace_period_entity.dart';
import '../../../installments/domain/entities/payment_entity.dart';
import '../entities/transaction_entity.dart';

class PayInstallmentPaymentParams {
  const PayInstallmentPaymentParams({
    required this.payment,
    required this.now,
  });

  final PaymentEntity payment;
  final DateTime now;
}

class PayGracePeriodParams {
  const PayGracePeriodParams({
    required this.gracePeriod,
    required this.now,
  });

  final GracePeriodEntity gracePeriod;
  final DateTime now;
}

class ReversePaymentParams {
  const ReversePaymentParams({
    this.transactionId,
    required this.relatedId,
    required this.relatedType,
    required this.now,
    this.reversalNote,
  });

  /// Optional — if not provided, datasource will look up the latest
  /// completed transaction whose `relatedId` matches.
  final String? transactionId;
  final String relatedId;
  final RelatedType relatedType;
  final DateTime now;
  final String? reversalNote;
}

class TransactionsFilter {
  const TransactionsFilter({
    this.fromYearMonth,
    this.toYearMonth,
    this.clientId,
    this.includeReversed = true,
    this.limit = 100,
  });

  final String? fromYearMonth;
  final String? toYearMonth;
  final String? clientId;
  final bool includeReversed;
  final int limit;
}

abstract class PaymentRepository {
  Future<Either<Failure, void>> payInstallmentPayment(
    PayInstallmentPaymentParams params,
  );

  Future<Either<Failure, void>> payGracePeriod(
    PayGracePeriodParams params,
  );

  Future<Either<Failure, void>> reversePayment(
    ReversePaymentParams params,
  );

  Stream<List<TransactionEntity>> watchTransactionsForClient(String clientId);

  Future<Either<Failure, List<TransactionEntity>>> getTransactions(
    TransactionsFilter filter,
  );
}
