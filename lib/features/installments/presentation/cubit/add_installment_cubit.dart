// lib/features/installments/presentation/cubit/add_installment_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../features/clients/domain/entities/client_entity.dart';
import '../../domain/repositories/installment_repository.dart';
import '../../domain/usecases/add_installment_use_case.dart';
import 'add_installment_state.dart';

class AddInstallmentCubit extends Cubit<AddInstallmentState> {
  AddInstallmentCubit(this._addInstallment)
      : super(const AddInstallmentState());

  final AddInstallmentUseCase _addInstallment;

  void updateSummary({
    required double capital,
    required double profitAmount,
    required int durationMonths,
    required bool isOfficeClient,
    required double discountPerMonth,
  }) {
    if (durationMonths <= 0) return;
    final effectiveProfitAmount = profitAmount - discountPerMonth * durationMonths;
    final effectiveTotalDebt = capital + effectiveProfitAmount;
    final effectiveMonthlyAmount = effectiveTotalDebt / durationMonths;
    final officeCommissionAmount = isOfficeClient
        ? capital * AppConstants.kOfficeCommissionRate
        : 0.0;

    emit(state.copyWith(
      monthlyAmount: effectiveMonthlyAmount,
      totalDebt: effectiveTotalDebt,
      durationMonths: durationMonths,
      officeCommissionAmount: officeCommissionAmount,
      discountPerMonth: discountPerMonth,
    ));
  }

  Future<void> save({
    required String clientId,
    required ClientType clientType,
    required bool officeCommissionPaidAtCreation,
    required String itemName,
    required double capital,
    required double profitAmount,
    required double discountPerMonth,
    required int durationMonths,
    required DateTime startDate,
  }) async {
    emit(state.copyWith(status: AddInstallmentStatus.saving));

    final result = await _addInstallment(
      AddInstallmentParams(
        clientId: clientId,
        clientType: clientType,
        officeCommissionPaidAtCreation: officeCommissionPaidAtCreation,
        itemName: itemName.trim(),
        capital: capital,
        profitAmount: profitAmount,
        discountPerMonth: discountPerMonth,
        durationMonths: durationMonths,
        startDate: startDate,
      ),
    );
    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(
        status: AddInstallmentStatus.failure,
        errorMessage: failure.message,
      )),
      (installment) => emit(state.copyWith(
        status: AddInstallmentStatus.saved,
        savedInstallment: installment,
      )),
    );
  }
}
