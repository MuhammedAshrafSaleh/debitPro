// lib/features/installments/presentation/cubit/add_installment_state.dart

import 'package:equatable/equatable.dart';

import '../../domain/entities/installment_entity.dart';

enum AddInstallmentStatus { initial, saving, saved, failure }

class AddInstallmentState extends Equatable {
  const AddInstallmentState({
    this.status = AddInstallmentStatus.initial,
    this.monthlyAmount = 0,
    this.totalDebt = 0,
    this.durationMonths = 12,
    this.officeCommissionAmount = 0,
    this.discountPerMonth = 0,
    this.savedInstallment,
    this.errorMessage,
  });

  final AddInstallmentStatus status;
  final double monthlyAmount;
  final double totalDebt;
  final int durationMonths;
  final double officeCommissionAmount;
  final double discountPerMonth;
  final InstallmentEntity? savedInstallment;
  final String? errorMessage;

  bool get isSaving => status == AddInstallmentStatus.saving;
  bool get isSaved => status == AddInstallmentStatus.saved;

  AddInstallmentState copyWith({
    AddInstallmentStatus? status,
    double? monthlyAmount,
    double? totalDebt,
    int? durationMonths,
    double? officeCommissionAmount,
    double? discountPerMonth,
    InstallmentEntity? savedInstallment,
    String? errorMessage,
  }) =>
      AddInstallmentState(
        status: status ?? this.status,
        monthlyAmount: monthlyAmount ?? this.monthlyAmount,
        totalDebt: totalDebt ?? this.totalDebt,
        durationMonths: durationMonths ?? this.durationMonths,
        officeCommissionAmount:
            officeCommissionAmount ?? this.officeCommissionAmount,
        discountPerMonth: discountPerMonth ?? this.discountPerMonth,
        savedInstallment: savedInstallment ?? this.savedInstallment,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [
        status,
        monthlyAmount,
        totalDebt,
        durationMonths,
        officeCommissionAmount,
        discountPerMonth,
        savedInstallment,
        errorMessage,
      ];
}
