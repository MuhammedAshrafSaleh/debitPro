// lib/features/installments/presentation/cubit/installment_tracking_state.dart

import 'package:equatable/equatable.dart';

import '../../domain/entities/installment_entity.dart';
import '../../domain/entities/payment_entity.dart';

abstract class InstallmentTrackingState extends Equatable {
  const InstallmentTrackingState();

  @override
  List<Object?> get props => [];
}

class InstallmentTrackingInitial extends InstallmentTrackingState {
  const InstallmentTrackingInitial();
}

class InstallmentTrackingLoading extends InstallmentTrackingState {
  const InstallmentTrackingLoading();
}

class InstallmentTrackingLoaded extends InstallmentTrackingState {
  const InstallmentTrackingLoaded({
    required this.installment,
    required this.payments,
  });

  final InstallmentEntity installment;
  final List<PaymentEntity> payments;

  @override
  List<Object?> get props => [installment, payments];
}

class InstallmentTrackingFailure extends InstallmentTrackingState {
  const InstallmentTrackingFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class InstallmentTrackingCommissionLoading extends InstallmentTrackingState {
  const InstallmentTrackingCommissionLoading({
    required this.installment,
    required this.payments,
  });

  final InstallmentEntity installment;
  final List<PaymentEntity> payments;

  @override
  List<Object?> get props => [installment, payments];
}
