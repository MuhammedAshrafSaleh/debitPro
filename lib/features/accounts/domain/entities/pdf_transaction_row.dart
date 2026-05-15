// lib/features/accounts/domain/entities/pdf_transaction_row.dart

import '../../../payments/domain/entities/transaction_entity.dart';

class PdfTransactionRow {
  const PdfTransactionRow({
    required this.clientName,
    required this.itemName,
    required this.relatedType,
    required this.paidDate,
    required this.amount,
    required this.status,
    this.profitPortion,
  });

  final String clientName;
  final String itemName;
  final RelatedType relatedType;
  final DateTime paidDate;
  final double amount;
  final TransactionStatus status;
  final double? profitPortion;
}
