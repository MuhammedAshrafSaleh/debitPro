// lib/features/payments/presentation/bloc/payment_event.dart

import 'package:equatable/equatable.dart';

import '../../../grace_periods/domain/entities/grace_period_entity.dart';
import '../../../installments/domain/entities/payment_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/payment_repository.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class LoadPayments extends PaymentEvent {
  const LoadPayments({this.filter});

  final TransactionsFilter? filter;

  @override
  List<Object?> get props => [filter];
}

class PayInstallmentPaymentEvent extends PaymentEvent {
  const PayInstallmentPaymentEvent({required this.payment, required this.now});

  final PaymentEntity payment;
  final DateTime now;

  @override
  List<Object?> get props => [payment, now];
}

class PayGracePeriodEvent extends PaymentEvent {
  const PayGracePeriodEvent({required this.gracePeriod, required this.now});

  final GracePeriodEntity gracePeriod;
  final DateTime now;

  @override
  List<Object?> get props => [gracePeriod, now];
}

class ReversePaymentEvent extends PaymentEvent {
  const ReversePaymentEvent({
    this.transactionId,
    required this.relatedId,
    required this.relatedType,
    required this.now,
    this.reversalNote,
  });

  /// Optional — if null, the repository will look up the latest completed
  /// transaction for [relatedId].
  final String? transactionId;
  final String relatedId;
  final RelatedType relatedType;
  final DateTime now;
  final String? reversalNote;

  @override
  List<Object?> get props =>
      [transactionId, relatedId, relatedType, now, reversalNote];
}
