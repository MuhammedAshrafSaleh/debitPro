// lib/features/payments/presentation/bloc/payment_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/payment_repository.dart';
import '../../domain/usecases/get_transactions_use_case.dart';
import '../../domain/usecases/pay_grace_period_use_case.dart';
import '../../domain/usecases/pay_installment_payment_use_case.dart';
import '../../domain/usecases/reverse_payment_use_case.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc(
    this._payInstallment,
    this._payGracePeriod,
    this._reversePayment,
    this._getTransactions,
  ) : super(const PaymentState()) {
    on<LoadPayments>(_onLoad);
    on<PayInstallmentPaymentEvent>(_onPayInstallment);
    on<PayGracePeriodEvent>(_onPayGracePeriod);
    on<ReversePaymentEvent>(_onReverse);
  }

  final PayInstallmentPaymentUseCase _payInstallment;
  final PayGracePeriodUseCase _payGracePeriod;
  final ReversePaymentUseCase _reversePayment;
  final GetTransactionsUseCase _getTransactions;

  Future<void> _onLoad(LoadPayments event, Emitter<PaymentState> emit) async {
    emit(state.copyWith(
      status: PaymentStatusUi.loading,
      clearFailureMessage: true,
    ));
    final result = await _getTransactions(
      event.filter ?? const TransactionsFilter(),
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(
        status: PaymentStatusUi.failure,
        failureMessage: failure.message,
      )),
      (txs) => emit(state.copyWith(
        status: PaymentStatusUi.loaded,
        transactions: txs,
      )),
    );
  }

  Future<void> _onPayInstallment(
    PayInstallmentPaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(state.copyWith(
      actionStatus: PaymentActionStatus.loading,
      actionKind: PaymentActionKind.pay,
      clearActionMessage: true,
    ));
    final result = await _payInstallment(
      PayInstallmentPaymentParams(payment: event.payment, now: event.now),
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: PaymentActionStatus.failure,
        actionKind: PaymentActionKind.pay,
        actionMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        actionStatus: PaymentActionStatus.success,
        actionKind: PaymentActionKind.pay,
        actionMessage: 'تم تسجيل الدفعة بنجاح',
      )),
    );
  }

  Future<void> _onPayGracePeriod(
    PayGracePeriodEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(state.copyWith(
      actionStatus: PaymentActionStatus.loading,
      actionKind: PaymentActionKind.pay,
      clearActionMessage: true,
    ));
    final result = await _payGracePeriod(
      PayGracePeriodParams(gracePeriod: event.gracePeriod, now: event.now),
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: PaymentActionStatus.failure,
        actionKind: PaymentActionKind.pay,
        actionMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        actionStatus: PaymentActionStatus.success,
        actionKind: PaymentActionKind.pay,
        actionMessage: 'تم سداد المهلة بنجاح',
      )),
    );
  }

  Future<void> _onReverse(
    ReversePaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(state.copyWith(
      actionStatus: PaymentActionStatus.loading,
      actionKind: PaymentActionKind.reverse,
      clearActionMessage: true,
    ));
    final result = await _reversePayment(
      ReversePaymentParams(
        transactionId: event.transactionId,
        relatedId: event.relatedId,
        relatedType: event.relatedType,
        now: event.now,
        reversalNote: event.reversalNote,
      ),
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: PaymentActionStatus.failure,
        actionKind: PaymentActionKind.reverse,
        actionMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        actionStatus: PaymentActionStatus.success,
        actionKind: PaymentActionKind.reverse,
        actionMessage: 'تم إلغاء العملية',
      )),
    );
  }
}
