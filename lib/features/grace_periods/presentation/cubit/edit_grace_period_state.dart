// lib/features/grace_periods/presentation/cubit/edit_grace_period_state.dart

import 'package:equatable/equatable.dart';

import '../../domain/entities/grace_period_entity.dart';

enum EditGracePeriodStatus { initial, loading, loaded, saving, saved, failure }

class EditGracePeriodState extends Equatable {
  const EditGracePeriodState({
    this.status = EditGracePeriodStatus.initial,
    this.gracePeriod,
    this.officeCommissionAmount = 0,
    this.savedGracePeriod,
    this.errorMessage,
  });

  final EditGracePeriodStatus status;
  final GracePeriodEntity? gracePeriod;
  final double officeCommissionAmount;
  final GracePeriodEntity? savedGracePeriod;
  final String? errorMessage;

  bool get isLoading => status == EditGracePeriodStatus.loading;
  bool get isSaving => status == EditGracePeriodStatus.saving;
  bool get isSaved => status == EditGracePeriodStatus.saved;

  EditGracePeriodState copyWith({
    EditGracePeriodStatus? status,
    GracePeriodEntity? gracePeriod,
    double? officeCommissionAmount,
    GracePeriodEntity? savedGracePeriod,
    String? errorMessage,
  }) =>
      EditGracePeriodState(
        status: status ?? this.status,
        gracePeriod: gracePeriod ?? this.gracePeriod,
        officeCommissionAmount:
            officeCommissionAmount ?? this.officeCommissionAmount,
        savedGracePeriod: savedGracePeriod ?? this.savedGracePeriod,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [
        status,
        gracePeriod,
        officeCommissionAmount,
        savedGracePeriod,
        errorMessage,
      ];
}
