// lib/features/installments/presentation/cubit/edit_installment_state.dart

import 'package:equatable/equatable.dart';

import '../../domain/entities/installment_entity.dart';

enum EditInstallmentStatus { initial, loading, loaded, saving, saved, failure }

class EditInstallmentState extends Equatable {
  const EditInstallmentState({
    this.status = EditInstallmentStatus.initial,
    this.installment,
    this.monthlyAmount = 0,
    this.totalDebt = 0,
    this.durationMonths = 12,
    this.officeCommissionAmount = 0,
    this.savedInstallment,
    this.errorMessage,
  });

  final EditInstallmentStatus status;
  final InstallmentEntity? installment;
  final double monthlyAmount;
  final double totalDebt;
  final int durationMonths;
  final double officeCommissionAmount;
  final InstallmentEntity? savedInstallment;
  final String? errorMessage;

  bool get isLoading => status == EditInstallmentStatus.loading;
  bool get isLoaded => status == EditInstallmentStatus.loaded;
  bool get isSaving => status == EditInstallmentStatus.saving;
  bool get isSaved => status == EditInstallmentStatus.saved;

  EditInstallmentState copyWith({
    EditInstallmentStatus? status,
    InstallmentEntity? installment,
    double? monthlyAmount,
    double? totalDebt,
    int? durationMonths,
    double? officeCommissionAmount,
    InstallmentEntity? savedInstallment,
    String? errorMessage,
  }) =>
      EditInstallmentState(
        status: status ?? this.status,
        installment: installment ?? this.installment,
        monthlyAmount: monthlyAmount ?? this.monthlyAmount,
        totalDebt: totalDebt ?? this.totalDebt,
        durationMonths: durationMonths ?? this.durationMonths,
        officeCommissionAmount:
            officeCommissionAmount ?? this.officeCommissionAmount,
        savedInstallment: savedInstallment ?? this.savedInstallment,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [
        status,
        installment,
        monthlyAmount,
        totalDebt,
        durationMonths,
        officeCommissionAmount,
        savedInstallment,
        errorMessage,
      ];
}
