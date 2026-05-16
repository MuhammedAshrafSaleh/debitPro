// lib/features/installments/domain/entities/installment_entity.dart

import 'package:equatable/equatable.dart';

enum InstallmentStatus { active, completed }

class InstallmentEntity extends Equatable {
  const InstallmentEntity({
    required this.id,
    required this.clientId,
    required this.itemName,
    required this.capital,
    required this.profitAmount,
    required this.discountPerMonth,
    required this.profitPerPayment,
    required this.monthlyAmount,
    required this.totalDebt,
    required this.durationMonths,
    required this.startDate,
    required this.firstPaymentDueDate,
    required this.officeCommissionAmount,
    required this.officeCommissionPaid,
    this.officeCommissionPaidAt,
    required this.paidPaymentsCount,
    required this.totalPaymentsCount,
    required this.totalPaidAmount,
    required this.recognizedProfit,
    required this.status,
    required this.editLocked,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String clientId;
  final String itemName;
  final double capital;
  final double profitAmount;
  final double discountPerMonth;
  final double profitPerPayment;
  final double monthlyAmount;
  final double totalDebt;
  final int durationMonths;
  final DateTime startDate;
  final DateTime firstPaymentDueDate;
  final double officeCommissionAmount;
  final bool officeCommissionPaid;
  final DateTime? officeCommissionPaidAt;
  final int paidPaymentsCount;
  final int totalPaymentsCount;
  final double totalPaidAmount;
  final double recognizedProfit;
  final InstallmentStatus status;
  final bool editLocked;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        clientId,
        itemName,
        capital,
        profitAmount,
        discountPerMonth,
        profitPerPayment,
        monthlyAmount,
        totalDebt,
        durationMonths,
        startDate,
        firstPaymentDueDate,
        officeCommissionAmount,
        officeCommissionPaid,
        officeCommissionPaidAt,
        paidPaymentsCount,
        totalPaymentsCount,
        totalPaidAmount,
        recognizedProfit,
        status,
        editLocked,
        createdAt,
        updatedAt,
      ];
}
