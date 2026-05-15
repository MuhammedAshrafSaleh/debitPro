// lib/features/installments/presentation/cubit/installment_tracking_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/delete_installment_use_case.dart';
import '../../domain/usecases/get_installment_with_payments_use_case.dart';
import '../../domain/usecases/pay_office_commission_use_case.dart';
import 'installment_tracking_state.dart';

class InstallmentTrackingCubit extends Cubit<InstallmentTrackingState> {
  InstallmentTrackingCubit(
    this._getInstallmentWithPayments,
    this._payOfficeCommission,
    this._deleteInstallment,
  ) : super(const InstallmentTrackingInitial());

  final GetInstallmentWithPaymentsUseCase _getInstallmentWithPayments;
  final PayOfficeCommissionUseCase _payOfficeCommission;
  final DeleteInstallmentUseCase _deleteInstallment;

  Future<void> load(String installmentId) async {
    emit(const InstallmentTrackingLoading());
    final result = await _getInstallmentWithPayments(installmentId);
    if (isClosed) return;
    result.fold(
      (failure) => emit(InstallmentTrackingFailure(failure.message)),
      (data) => emit(InstallmentTrackingLoaded(
        installment: data.installment,
        payments: data.payments,
      )),
    );
  }

  Future<void> payOfficeCommission(String installmentId) async {
    final current = state;
    if (current is! InstallmentTrackingLoaded) return;

    emit(InstallmentTrackingCommissionLoading(
      installment: current.installment,
      payments: current.payments,
    ));

    final result = await _payOfficeCommission(installmentId);
    if (isClosed) return;
    result.fold(
      (failure) => emit(InstallmentTrackingLoaded(
        installment: current.installment,
        payments: current.payments,
      )),
      (_) => load(installmentId),
    );
  }

  Future<void> delete(String installmentId) async {
    final current = state;
    if (current is! InstallmentTrackingLoaded) return;
    emit(const InstallmentTrackingLoading());
    final result = await _deleteInstallment(installmentId);
    if (isClosed) return;
    result.fold(
      (failure) => emit(InstallmentTrackingFailure(failure.message)),
      (_) => emit(const InstallmentTrackingDeleted()),
    );
  }
}
