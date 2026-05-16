// lib/features/clients/presentation/cubit/edit_client_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/client_entity.dart';
import '../../domain/repositories/client_repository.dart';
import '../../domain/usecases/delete_client_use_case.dart' show DeleteClientParams, DeleteClientUseCase;
import '../../domain/usecases/edit_client_use_case.dart';
import 'edit_client_state.dart';

class EditClientCubit extends Cubit<EditClientState> {
  EditClientCubit(this._editClient, this._deleteClient)
      : super(const EditClientInitial());

  final EditClientUseCase _editClient;
  final DeleteClientUseCase _deleteClient;

  Future<void> save({
    required String id,
    required String fullName,
    required String phone,
    required Gender gender,
    required DocumentationType documentationType,
    required ClientType clientType,
    String? notes,
  }) async {
    emit(const EditClientSaving());
    final result = await _editClient(
      EditClientParams(
        id: id,
        fullName: fullName.trim(),
        phone: phone.trim(),
        gender: gender,
        documentationType: documentationType,
        clientType: clientType,
        notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
      ),
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(EditClientFailure(failure.message)),
      (client) => emit(EditClientSaved(client)),
    );
  }

  Future<void> delete({
    required String id,
    required int totalDuePaymentsCount,
  }) async {
    emit(const EditClientSaving());
    final result = await _deleteClient(
      DeleteClientParams(id: id, totalDuePaymentsCount: totalDuePaymentsCount),
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(EditClientFailure(failure.message)),
      (_) => emit(const EditClientDeleted()),
    );
  }
}
