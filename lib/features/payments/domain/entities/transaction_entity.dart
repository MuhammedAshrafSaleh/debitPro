// lib/features/payments/domain/entities/transaction_entity.dart

import 'package:equatable/equatable.dart';

enum TransactionStatus { completed, reversed }

enum TransactionType { payment, officeCommission }

enum RelatedType { installmentPayment, gracePeriod, officeCommission }

class TransactionEntity extends Equatable {
  const TransactionEntity({
    required this.id,
    required this.clientId,
    required this.relatedId,
    required this.relatedType,
    this.installmentId,
    this.gracePeriodId,
    required this.amount,
    this.profitPortion,
    required this.type,
    required this.status,
    required this.yearMonth,
    required this.paidDate,
    this.reversedAt,
    this.reversalNote,
    required this.createdAt,
  });

  final String id;
  final String clientId;
  final String relatedId;
  final RelatedType relatedType;
  final String? installmentId;
  final String? gracePeriodId;
  final double amount;
  final double? profitPortion;
  final TransactionType type;
  final TransactionStatus status;
  final String yearMonth;
  final DateTime paidDate;
  final DateTime? reversedAt;
  final String? reversalNote;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        clientId,
        relatedId,
        relatedType,
        installmentId,
        gracePeriodId,
        amount,
        profitPortion,
        type,
        status,
        yearMonth,
        paidDate,
        reversedAt,
        reversalNote,
        createdAt,
      ];
}

extension RelatedTypeX on RelatedType {
  String get wireValue => switch (this) {
        RelatedType.installmentPayment => 'installment_payment',
        RelatedType.gracePeriod => 'grace_period',
        RelatedType.officeCommission => 'office_commission',
      };

  static RelatedType fromWire(String? value) => switch (value) {
        'installment_payment' => RelatedType.installmentPayment,
        'grace_period' => RelatedType.gracePeriod,
        'office_commission' => RelatedType.officeCommission,
        _ => RelatedType.installmentPayment,
      };
}

extension TransactionTypeX on TransactionType {
  String get wireValue => switch (this) {
        TransactionType.payment => 'payment',
        TransactionType.officeCommission => 'office_commission',
      };

  static TransactionType fromWire(String? value) => switch (value) {
        'office_commission' => TransactionType.officeCommission,
        _ => TransactionType.payment,
      };
}

extension TransactionStatusX on TransactionStatus {
  String get wireValue => name;

  static TransactionStatus fromWire(String? value) => switch (value) {
        'reversed' => TransactionStatus.reversed,
        _ => TransactionStatus.completed,
      };
}
