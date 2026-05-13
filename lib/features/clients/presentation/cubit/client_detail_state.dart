// lib/features/clients/presentation/cubit/client_detail_state.dart

import 'package:equatable/equatable.dart';

import '../../domain/entities/client_entity.dart';

abstract class ClientDetailState extends Equatable {
  const ClientDetailState();

  @override
  List<Object?> get props => [];
}

class ClientDetailInitial extends ClientDetailState {
  const ClientDetailInitial();
}

class ClientDetailLoading extends ClientDetailState {
  const ClientDetailLoading();
}

class ClientDetailLoaded extends ClientDetailState {
  const ClientDetailLoaded({required this.client});

  final ClientEntity client;

  @override
  List<Object?> get props => [client];
}

class ClientDetailFailure extends ClientDetailState {
  const ClientDetailFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
