// lib/features/installments/presentation/cubit/installment_tracking_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/payment_entity.dart';
import '../../domain/usecases/delete_installment_use_case.dart';
import '../../domain/usecases/get_installment_with_payments_use_case.dart';
import '../../domain/usecases/pay_installment_payment_use_case.dart';
import '../../domain/usecases/pay_office_commission_use_case.dart';
import '../../domain/usecases/reverse_installment_payment_use_case.dart';
import 'installment_tracking_state.dart';

class InstallmentTrackingCubit extends Cubit<InstallmentTrackingState> {
  InstallmentTrackingCubit(
    this._getInstallmentWithPayments,
    this._payOfficeCommission,
    this._deleteInstallment,
    this._payInstallmentPayment,
    this._reverseInstallmentPayment,
  ) : super(const InstallmentTrackingInitial());

  final GetInstallmentWithPaymentsUseCase _getInstallmentWithPayments;
  final PayOfficeCommissionUseCase _payOfficeCommission;
  final DeleteInstallmentUseCase _deleteInstallment;
  final PayInstallmentPaymentUseCase _payInstallmentPayment;
  final ReverseInstallmentPaymentUseCase _reverseInstallmentPayment;

  Future<void> load(String installmentId) async {
    emit(const InstallmentTrackingLoading());
    final result = await _getInstallmentWithPayments(installmentId);
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
    result.fold(
      (failure) => emit(InstallmentTrackingLoaded(
        installment: current.installment,
        payments: current.payments,
      )),
      (_) => load(installmentId),
    );
  }

  Future<void> payPayment(PaymentEntity payment) async {
    final current = state;
    if (current is! InstallmentTrackingLoaded) return;
    final result = await _payInstallmentPayment(
      PayInstallmentPaymentParams(payment: payment, now: DateTime.now()),
    );
    result.fold(
      (failure) => emit(InstallmentTrackingPaymentError(
        message: failure.message,
        installment: current.installment,
        payments: current.payments,
      )),
      (_) {
        emit(InstallmentTrackingPaymentSuccess(
          installment: current.installment,
          payments: current.payments,
        ));
        load(payment.installmentId);
      },
    );
  }

  Future<void> reversePayment(PaymentEntity payment) async {
    final current = state;
    if (current is! InstallmentTrackingLoaded) return;
    final result = await _reverseInstallmentPayment(payment);
    result.fold(
      (failure) => emit(InstallmentTrackingPaymentError(
        message: failure.message,
        installment: current.installment,
        payments: current.payments,
      )),
      (_) {
        emit(InstallmentTrackingReverseSuccess(
          installment: current.installment,
          payments: current.payments,
        ));
        load(payment.installmentId);
      },
    );
  }

  Future<void> delete(String installmentId) async {
    final current = state;
    if (current is! InstallmentTrackingLoaded) return;
    emit(const InstallmentTrackingLoading());
    final result = await _deleteInstallment(installmentId);
    result.fold(
      (failure) => emit(InstallmentTrackingFailure(failure.message)),
      (_) => emit(const InstallmentTrackingDeleted()),
    );
  }
}
