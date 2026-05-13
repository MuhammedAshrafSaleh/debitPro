// lib/features/installments/domain/entities/payment_entity.dart

import 'package:equatable/equatable.dart';

import '../../../../core/utils/status_utils.dart';

class PaymentEntity extends Equatable {
  const PaymentEntity({
    required this.id,
    required this.clientId,
    required this.installmentId,
    required this.monthIndex,
    required this.dueDate,
    required this.dueMonth,
    required this.amount,
    required this.profitPortion,
    required this.status,
    this.paidDate,
    this.paidAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String clientId;
  final String installmentId;
  final int monthIndex;
  final DateTime dueDate;
  final String dueMonth;
  final double amount;
  final double profitPortion;
  final PaymentStatus status;
  final DateTime? paidDate;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        clientId,
        installmentId,
        monthIndex,
        dueDate,
        dueMonth,
        amount,
        profitPortion,
        status,
        paidDate,
        paidAt,
        createdAt,
        updatedAt,
      ];
}
