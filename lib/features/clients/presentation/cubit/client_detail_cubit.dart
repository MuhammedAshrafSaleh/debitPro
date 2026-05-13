// lib/features/clients/presentation/cubit/client_detail_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import '../../domain/usecases/get_client_detail_use_case.dart';
import 'client_detail_state.dart';

class ClientDetailCubit extends Cubit<ClientDetailState> {
  ClientDetailCubit(this._getClientDetail) : super(const ClientDetailInitial());

  final GetClientDetailUseCase _getClientDetail;
  final _log = Logger();

  Future<void> loadClient(String id) async {
    emit(const ClientDetailLoading());
    final result = await _getClientDetail(id);
    result.fold(
      (failure) {
        _log.e('loadClient', error: failure.message);
        emit(ClientDetailFailure(failure.message));
      },
      (client) => emit(ClientDetailLoaded(client: client)),
    );
  }
}
