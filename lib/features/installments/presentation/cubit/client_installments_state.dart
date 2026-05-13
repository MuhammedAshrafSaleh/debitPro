// lib/features/installments/presentation/cubit/client_installments_state.dart

import 'package:equatable/equatable.dart';

import '../../domain/entities/installment_entity.dart';

abstract class ClientInstallmentsState extends Equatable {
  const ClientInstallmentsState();

  @override
  List<Object?> get props => [];
}

class ClientInstallmentsLoading extends ClientInstallmentsState {
  const ClientInstallmentsLoading();
}

class ClientInstallmentsLoaded extends ClientInstallmentsState {
  const ClientInstallmentsLoaded(this.installments);

  final List<InstallmentEntity> installments;

  @override
  List<Object?> get props => [installments];
}

class ClientInstallmentsFailure extends ClientInstallmentsState {
  const ClientInstallmentsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
