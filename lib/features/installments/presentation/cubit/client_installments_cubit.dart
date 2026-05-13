// lib/features/installments/presentation/cubit/client_installments_cubit.dart

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/watch_installments_for_client_use_case.dart';
import 'client_installments_state.dart';

class ClientInstallmentsCubit extends Cubit<ClientInstallmentsState> {
  ClientInstallmentsCubit(this._watchInstallments)
      : super(const ClientInstallmentsLoading());

  final WatchInstallmentsForClientUseCase _watchInstallments;
  StreamSubscription<dynamic>? _subscription;

  void watch(String clientId) {
    emit(const ClientInstallmentsLoading());
    _subscription?.cancel();
    _subscription = _watchInstallments(clientId).listen(
      (installments) => emit(ClientInstallmentsLoaded(installments)),
      onError: (Object e) =>
          emit(ClientInstallmentsFailure(e.toString())),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
