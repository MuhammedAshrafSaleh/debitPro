// lib/features/clients/presentation/cubit/edit_client_state.dart

import 'package:equatable/equatable.dart';

import '../../domain/entities/client_entity.dart';

abstract class EditClientState extends Equatable {
  const EditClientState();

  @override
  List<Object?> get props => [];
}

class EditClientInitial extends EditClientState {
  const EditClientInitial();
}

class EditClientSaving extends EditClientState {
  const EditClientSaving();
}

class EditClientSaved extends EditClientState {
  const EditClientSaved(this.client);

  final ClientEntity client;

  @override
  List<Object?> get props => [client];
}

class EditClientDeleted extends EditClientState {
  const EditClientDeleted();
}

class EditClientFailure extends EditClientState {
  const EditClientFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
