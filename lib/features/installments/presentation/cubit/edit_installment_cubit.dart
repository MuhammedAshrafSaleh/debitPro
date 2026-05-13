// lib/features/installments/presentation/cubit/edit_installment_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/repositories/installment_repository.dart';
import '../../domain/usecases/edit_installment_use_case.dart';
import '../../domain/usecases/get_installment_with_payments_use_case.dart';
import 'edit_installment_state.dart';

class EditInstallmentCubit extends Cubit<EditInstallmentState> {
  EditInstallmentCubit(
    this._getInstallmentWithPayments,
    this._editInstallment,
  ) : super(const EditInstallmentState());

  final GetInstallmentWithPaymentsUseCase _getInstallmentWithPayments;
  final EditInstallmentUseCase _editInstallment;

  Future<void> load(String installmentId) async {
    emit(state.copyWith(status: EditInstallmentStatus.loading));
    final result = await _getInstallmentWithPayments(installmentId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: EditInstallmentStatus.failure,
        errorMessage: failure.message,
      )),
      (data) {
        final inst = data.installment;
        emit(state.copyWith(
          status: EditInstallmentStatus.loaded,
          installment: inst,
          monthlyAmount: inst.monthlyAmount,
          totalDebt: inst.totalDebt,
          durationMonths: inst.durationMonths,
          officeCommissionAmount: inst.officeCommissionAmount,
        ));
      },
    );
  }

  void updateSummary({
    required double capital,
    required double profitAmount,
    required int durationMonths,
  }) {
    if (durationMonths <= 0) return;
    final totalDebt = capital + profitAmount;
    final monthlyAmount = totalDebt / durationMonths;
    final officeCommissionAmount =
        (state.installment?.officeCommissionAmount ?? 0) > 0
            ? capital * AppConstants.kOfficeCommissionRate
            : 0.0;

    emit(state.copyWith(
      monthlyAmount: monthlyAmount,
      totalDebt: totalDebt,
      durationMonths: durationMonths,
      officeCommissionAmount: officeCommissionAmount,
    ));
  }

  Future<void> save({
    required String installmentId,
    required String clientId,
    required String itemName,
    required double capital,
    required double profitAmount,
    required int durationMonths,
    required DateTime startDate,
  }) async {
    emit(state.copyWith(status: EditInstallmentStatus.saving));

    final result = await _editInstallment(
      EditInstallmentParams(
        id: installmentId,
        clientId: clientId,
        itemName: itemName.trim(),
        capital: capital,
        profitAmount: profitAmount,
        durationMonths: durationMonths,
        startDate: startDate,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: EditInstallmentStatus.failure,
        errorMessage: failure.message,
      )),
      (installment) => emit(state.copyWith(
        status: EditInstallmentStatus.saved,
        savedInstallment: installment,
      )),
    );
  }
}
