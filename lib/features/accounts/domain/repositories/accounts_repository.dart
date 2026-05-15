// lib/features/accounts/domain/repositories/accounts_repository.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../clients/domain/entities/client_entity.dart';
import '../../../grace_periods/domain/entities/grace_period_entity.dart';
import '../../../installments/domain/entities/installment_entity.dart';
import '../../../installments/domain/entities/payment_entity.dart';
import '../entities/accounts_filter.dart';
import '../entities/pdf_transaction_row.dart';

class AccountsRawData {
  const AccountsRawData({
    required this.payments,
    required this.gracePeriods,
    required this.installmentsById,
    required this.clientsById,
  });

  final List<PaymentEntity> payments;
  final List<GracePeriodEntity> gracePeriods;
  final Map<String, InstallmentEntity> installmentsById;
  final Map<String, ClientEntity> clientsById;
}

abstract class AccountsRepository {
  /// Fetches payments, grace periods, and the clients/installments they
  /// reference, scoped by the date range portion of [filter]. The use case
  /// joins these into the unified item list and computes the summary.
  Future<Either<Failure, AccountsRawData>> fetchAccountsData(
    AccountsFilter filter,
  );

  /// Fetches actual transactions (payments, office commissions, reversals)
  /// from the transactions collection, enriched with client and item names.
  Future<Either<Failure, List<PdfTransactionRow>>> fetchTransactionsPdf(
    AccountsFilter filter,
  );
}
