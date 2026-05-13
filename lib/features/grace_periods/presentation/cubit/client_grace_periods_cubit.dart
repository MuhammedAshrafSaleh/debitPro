// lib/features/grace_periods/presentation/cubit/client_grace_periods_cubit.dart

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/pay_grace_period_office_commission_use_case.dart';
import '../../domain/usecases/pay_grace_period_use_case.dart';
import '../../domain/usecases/watch_grace_periods_for_client_use_case.dart';
import 'client_grace_periods_state.dart';

class ClientGracePeriodsCubit extends Cubit<ClientGracePeriodsState> {
  ClientGracePeriodsCubit(
    this._watchGracePeriods,
    this._payGracePeriod,
    this._payOfficeCommission,
  ) : super(const ClientGracePeriodsInitial());

  final WatchGracePeriodsForClientUseCase _watchGracePeriods;
  final PayGracePeriodUseCase _payGracePeriod;
  final PayGracePeriodOfficeCommissionUseCase _payOfficeCommission;
  StreamSubscription<dynamic>? _sub;

  void watch(String clientId) {
    emit(const ClientGracePeriodsLoading());
    _sub?.cancel();
    _sub = _watchGracePeriods(clientId).listen(
      (gracePeriods) => emit(ClientGracePeriodsLoaded(gracePeriods)),
      onError: (Object e) => emit(ClientGracePeriodsFailure(e.toString())),
    );
  }

  Future<void> payGracePeriod(String gracePeriodId) async {
    final current = state;
    if (current is! ClientGracePeriodsLoaded) return;
    emit(current.copyWith(
      actionStatus: GracePeriodActionStatus.loading,
      actionType: GracePeriodActionType.payGracePeriod,
    ));
    final result = await _payGracePeriod(gracePeriodId);
    result.fold(
      (failure) => emit(current.copyWith(
        actionStatus: GracePeriodActionStatus.failure,
        actionType: GracePeriodActionType.payGracePeriod,
        actionMessage: failure.message,
      )),
      (_) => emit(current.copyWith(
        actionStatus: GracePeriodActionStatus.success,
        actionType: GracePeriodActionType.payGracePeriod,
      )),
    );
  }

  Future<void> payOfficeCommission(String gracePeriodId) async {
    final current = state;
    if (current is! ClientGracePeriodsLoaded) return;
    emit(current.copyWith(
      actionStatus: GracePeriodActionStatus.loading,
      actionType: GracePeriodActionType.payOfficeCommission,
    ));
    final result = await _payOfficeCommission(gracePeriodId);
    result.fold(
      (failure) => emit(current.copyWith(
        actionStatus: GracePeriodActionStatus.failure,
        actionType: GracePeriodActionType.payOfficeCommission,
        actionMessage: failure.message,
      )),
      (_) => emit(current.copyWith(
        actionStatus: GracePeriodActionStatus.success,
        actionType: GracePeriodActionType.payOfficeCommission,
      )),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
