// lib/features/grace_periods/presentation/cubit/add_grace_period_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../features/clients/domain/entities/client_entity.dart';
import '../../domain/repositories/grace_period_repository.dart';
import '../../domain/usecases/add_grace_period_use_case.dart';
import 'add_grace_period_state.dart';

class AddGracePeriodCubit extends Cubit<AddGracePeriodState> {
  AddGracePeriodCubit(this._addGracePeriod)
      : super(const AddGracePeriodState());

  final AddGracePeriodUseCase _addGracePeriod;

  void updateOfficeCommission({
    required double capital,
    required bool isOfficeClient,
  }) {
    final amount = isOfficeClient
        ? capital * AppConstants.kOfficeCommissionRate
        : 0.0;
    emit(state.copyWith(officeCommissionAmount: amount));
  }

  Future<void> save({
    required String clientId,
    required ClientType clientType,
    required bool officeCommissionPaidAtCreation,
    required String name,
    required double capital,
    required DateTime dueDate,
    String? notes,
  }) async {
    emit(state.copyWith(status: AddGracePeriodStatus.saving));

    final result = await _addGracePeriod(
      AddGracePeriodParams(
        clientId: clientId,
        clientType: clientType,
        officeCommissionPaidAtCreation: officeCommissionPaidAtCreation,
        name: name.trim(),
        capital: capital,
        dueDate: dueDate,
        notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
      ),
    );
    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(
        status: AddGracePeriodStatus.failure,
        errorMessage: failure.message,
      )),
      (gracePeriod) => emit(state.copyWith(
        status: AddGracePeriodStatus.saved,
        savedGracePeriod: gracePeriod,
      )),
    );
  }
}
