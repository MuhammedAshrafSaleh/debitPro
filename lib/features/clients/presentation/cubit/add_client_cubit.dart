// lib/features/clients/presentation/cubit/add_client_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/client_entity.dart';
import '../../domain/repositories/client_repository.dart';
import '../../domain/usecases/add_client_use_case.dart';
import 'add_client_state.dart';

class AddClientCubit extends Cubit<AddClientState> {
  AddClientCubit(this._addClient) : super(const AddClientInitial());

  final AddClientUseCase _addClient;

  Future<void> save({
    required String fullName,
    required String phone,
    required Gender gender,
    required DocumentationType documentationType,
    required ClientType clientType,
    String? notes,
  }) async {
    emit(const AddClientSaving());
    final result = await _addClient(
      AddClientParams(
        fullName: fullName.trim(),
        phone: phone.trim(),
        gender: gender,
        documentationType: documentationType,
        clientType: clientType,
        notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
      ),
    );
    result.fold(
      (failure) => emit(AddClientFailure(failure.message)),
      (client) => emit(AddClientSaved(client)),
    );
  }
}
