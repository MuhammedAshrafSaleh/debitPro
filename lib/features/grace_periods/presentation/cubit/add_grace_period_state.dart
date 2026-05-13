// lib/features/grace_periods/presentation/cubit/add_grace_period_state.dart

import 'package:equatable/equatable.dart';

import '../../domain/entities/grace_period_entity.dart';

enum AddGracePeriodStatus { initial, saving, saved, failure }

class AddGracePeriodState extends Equatable {
  const AddGracePeriodState({
    this.status = AddGracePeriodStatus.initial,
    this.officeCommissionAmount = 0,
    this.savedGracePeriod,
    this.errorMessage,
  });

  final AddGracePeriodStatus status;
  final double officeCommissionAmount;
  final GracePeriodEntity? savedGracePeriod;
  final String? errorMessage;

  bool get isSaving => status == AddGracePeriodStatus.saving;
  bool get isSaved => status == AddGracePeriodStatus.saved;

  AddGracePeriodState copyWith({
    AddGracePeriodStatus? status,
    double? officeCommissionAmount,
    GracePeriodEntity? savedGracePeriod,
    String? errorMessage,
  }) =>
      AddGracePeriodState(
        status: status ?? this.status,
        officeCommissionAmount:
            officeCommissionAmount ?? this.officeCommissionAmount,
        savedGracePeriod: savedGracePeriod ?? this.savedGracePeriod,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [
        status,
        officeCommissionAmount,
        savedGracePeriod,
        errorMessage,
      ];
}
