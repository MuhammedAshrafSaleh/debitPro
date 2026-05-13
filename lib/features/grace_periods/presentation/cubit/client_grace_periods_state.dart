// lib/features/grace_periods/presentation/cubit/client_grace_periods_state.dart

import 'package:equatable/equatable.dart';

import '../../domain/entities/grace_period_entity.dart';

enum GracePeriodActionStatus { idle, loading, success, failure }

enum GracePeriodActionType { none, payGracePeriod, payOfficeCommission }

abstract class ClientGracePeriodsState extends Equatable {
  const ClientGracePeriodsState();

  @override
  List<Object?> get props => [];
}

class ClientGracePeriodsInitial extends ClientGracePeriodsState {
  const ClientGracePeriodsInitial();
}

class ClientGracePeriodsLoading extends ClientGracePeriodsState {
  const ClientGracePeriodsLoading();
}

class ClientGracePeriodsLoaded extends ClientGracePeriodsState {
  const ClientGracePeriodsLoaded(
    this.gracePeriods, {
    this.actionStatus = GracePeriodActionStatus.idle,
    this.actionType = GracePeriodActionType.none,
    this.actionMessage,
  });

  final List<GracePeriodEntity> gracePeriods;
  final GracePeriodActionStatus actionStatus;
  final GracePeriodActionType actionType;
  final String? actionMessage;

  ClientGracePeriodsLoaded copyWith({
    List<GracePeriodEntity>? gracePeriods,
    GracePeriodActionStatus? actionStatus,
    GracePeriodActionType? actionType,
    String? actionMessage,
  }) =>
      ClientGracePeriodsLoaded(
        gracePeriods ?? this.gracePeriods,
        actionStatus: actionStatus ?? this.actionStatus,
        actionType: actionType ?? this.actionType,
        actionMessage: actionMessage ?? this.actionMessage,
      );

  @override
  List<Object?> get props =>
      [gracePeriods, actionStatus, actionType, actionMessage];
}

class ClientGracePeriodsFailure extends ClientGracePeriodsState {
  const ClientGracePeriodsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
