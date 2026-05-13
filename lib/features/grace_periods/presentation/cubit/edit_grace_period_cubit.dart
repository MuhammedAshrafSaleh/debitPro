// lib/features/grace_periods/presentation/cubit/edit_grace_period_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/grace_period_repository.dart';
import '../../domain/usecases/edit_grace_period_use_case.dart';
import '../../domain/usecases/get_grace_period_use_case.dart';
import 'edit_grace_period_state.dart';

class EditGracePeriodCubit extends Cubit<EditGracePeriodState> {
  EditGracePeriodCubit(
    this._getGracePeriod,
    this._editGracePeriod,
  ) : super(const EditGracePeriodState());

  final GetGracePeriodUseCase _getGracePeriod;
  final EditGracePeriodUseCase _editGracePeriod;

  Future<void> load(String gracePeriodId) async {
    emit(state.copyWith(status: EditGracePeriodStatus.loading));
    final result = await _getGracePeriod(gracePeriodId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: EditGracePeriodStatus.failure,
        errorMessage: failure.message,
      )),
      (gp) => emit(state.copyWith(
        status: EditGracePeriodStatus.loaded,
        gracePeriod: gp,
        officeCommissionAmount: gp.officeCommissionAmount,
      )),
    );
  }

  Future<void> save({
    required String gracePeriodId,
    required String clientId,
    required String name,
    required double capital,
    required DateTime dueDate,
    String? notes,
  }) async {
    emit(state.copyWith(status: EditGracePeriodStatus.saving));

    final result = await _editGracePeriod(
      EditGracePeriodParams(
        id: gracePeriodId,
        clientId: clientId,
        name: name.trim(),
        capital: capital,
        dueDate: dueDate,
        notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: EditGracePeriodStatus.failure,
        errorMessage: failure.message,
      )),
      (gracePeriod) => emit(state.copyWith(
        status: EditGracePeriodStatus.saved,
        savedGracePeriod: gracePeriod,
      )),
    );
  }
}
