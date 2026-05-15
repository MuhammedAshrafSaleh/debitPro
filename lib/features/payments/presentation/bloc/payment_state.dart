// lib/features/payments/presentation/bloc/payment_state.dart

import 'package:equatable/equatable.dart';

import '../../domain/entities/transaction_entity.dart';

enum PaymentActionKind { pay, reverse }

class PaymentState extends Equatable {
  const PaymentState({
    this.status = PaymentStatusUi.initial,
    this.transactions = const [],
    this.actionStatus = PaymentActionStatus.idle,
    this.actionKind,
    this.actionMessage,
    this.failureMessage,
  });

  final PaymentStatusUi status;
  final List<TransactionEntity> transactions;
  final PaymentActionStatus actionStatus;
  final PaymentActionKind? actionKind;
  final String? actionMessage;
  final String? failureMessage;

  PaymentState copyWith({
    PaymentStatusUi? status,
    List<TransactionEntity>? transactions,
    PaymentActionStatus? actionStatus,
    PaymentActionKind? actionKind,
    String? actionMessage,
    String? failureMessage,
    bool clearActionMessage = false,
    bool clearFailureMessage = false,
  }) {
    return PaymentState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      actionStatus: actionStatus ?? this.actionStatus,
      actionKind: actionKind ?? this.actionKind,
      actionMessage:
          clearActionMessage ? null : actionMessage ?? this.actionMessage,
      failureMessage:
          clearFailureMessage ? null : failureMessage ?? this.failureMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        transactions,
        actionStatus,
        actionKind,
        actionMessage,
        failureMessage,
      ];
}

enum PaymentStatusUi { initial, loading, loaded, failure }

enum PaymentActionStatus { idle, loading, success, failure }
