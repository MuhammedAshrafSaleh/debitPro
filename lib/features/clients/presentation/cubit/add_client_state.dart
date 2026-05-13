// lib/features/clients/presentation/cubit/add_client_state.dart

import 'package:equatable/equatable.dart';

import '../../domain/entities/client_entity.dart';

abstract class AddClientState extends Equatable {
  const AddClientState();

  @override
  List<Object?> get props => [];
}

class AddClientInitial extends AddClientState {
  const AddClientInitial();
}

class AddClientSaving extends AddClientState {
  const AddClientSaving();
}

class AddClientSaved extends AddClientState {
  const AddClientSaved(this.client);

  final ClientEntity client;

  @override
  List<Object?> get props => [client];
}

class AddClientFailure extends AddClientState {
  const AddClientFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
