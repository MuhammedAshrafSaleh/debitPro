// lib/features/accounts/domain/usecases/get_transactions_pdf_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/accounts_filter.dart';
import '../entities/pdf_transaction_row.dart';
import '../repositories/accounts_repository.dart';

class GetTransactionsPdfUseCase {
  GetTransactionsPdfUseCase(this._repository);

  final AccountsRepository _repository;

  Future<Either<Failure, List<PdfTransactionRow>>> call(
    AccountsFilter filter,
  ) async {
    try {
      return await _repository.fetchTransactionsPdf(filter);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
