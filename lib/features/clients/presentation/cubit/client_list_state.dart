// lib/features/clients/presentation/cubit/client_list_state.dart

import 'package:equatable/equatable.dart';

import '../../domain/entities/client_entity.dart';

abstract class ClientListState extends Equatable {
  const ClientListState();

  @override
  List<Object?> get props => [];
}

class ClientListInitial extends ClientListState {
  const ClientListInitial();
}

class ClientListLoading extends ClientListState {
  const ClientListLoading();
}

class ClientListLoaded extends ClientListState {
  const ClientListLoaded({
    required this.clients,
    required this.filter,
    this.searchQuery = '',
  });

  final List<ClientEntity> clients;
  final ClientFilter filter;
  final String searchQuery;

  ClientListLoaded copyWith({
    List<ClientEntity>? clients,
    ClientFilter? filter,
    String? searchQuery,
  }) =>
      ClientListLoaded(
        clients: clients ?? this.clients,
        filter: filter ?? this.filter,
        searchQuery: searchQuery ?? this.searchQuery,
      );

  @override
  List<Object?> get props => [clients, filter, searchQuery];
}

class ClientListFailure extends ClientListState {
  const ClientListFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
