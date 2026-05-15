// lib/features/dashboard/presentation/cubit/dashboard_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_dashboard_data_use_case.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._getDashboardData) : super(const DashboardState());

  final GetDashboardDataUseCase _getDashboardData;

  Future<void> load() async {
    emit(state.copyWith(
      status: DashboardStatus.loading,
      clearFailure: true,
    ));
    final result = await _getDashboardData(now: DateTime.now());
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(
        status: DashboardStatus.failure,
        failureMessage: failure.message,
      )),
      (data) => emit(state.copyWith(
        status: DashboardStatus.loaded,
        data: data,
      )),
    );
  }

  Future<void> refresh() => load();
}
