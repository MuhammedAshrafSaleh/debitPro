// lib/features/clients/presentation/cubit/client_list_cubit.dart

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import '../../domain/entities/client_entity.dart';
import '../../domain/usecases/watch_clients_use_case.dart';
import 'client_list_state.dart';

class ClientListCubit extends Cubit<ClientListState> {
  ClientListCubit(this._watchClients) : super(const ClientListInitial());

  final WatchClientsUseCase _watchClients;
  final _log = Logger();
  StreamSubscription<dynamic>? _sub;
  ClientFilter _currentFilter = ClientFilter.all;
  List<ClientEntity> _allClients = [];
  String _searchQuery = '';

  void loadClients({ClientFilter filter = ClientFilter.all}) {
    _currentFilter = filter;
    _searchQuery = '';
    emit(const ClientListLoading());
    _sub?.cancel();
    _sub = _watchClients(filter).listen(
      (clients) {
        if (isClosed) return;
        _allClients = clients;
        emit(ClientListLoaded(
          clients: _applyFilters(_allClients),
          filter: _currentFilter,
        ));
      },
      onError: (Object e) {
        if (isClosed) return;
        _log.e('watchClients', error: e);
        emit(ClientListFailure(e.toString()));
      },
    );
  }

  void changeFilter(ClientFilter filter) {
    if (filter == _currentFilter) return;
    _currentFilter = filter;
    if (state is ClientListLoaded) {
      emit((state as ClientListLoaded).copyWith(
        clients: _applyFilters(_allClients),
        filter: _currentFilter,
        searchQuery: _searchQuery,
      ));
    }
  }

  void search(String query) {
    _searchQuery = query.trim().toLowerCase();
    if (state is ClientListLoaded) {
      emit((state as ClientListLoaded).copyWith(
        clients: _applyFilters(_allClients),
        searchQuery: _searchQuery,
      ));
    }
  }

  List<ClientEntity> _applyFilters(List<ClientEntity> all) {
    var result = all;
    switch (_currentFilter) {
      case ClientFilter.electronic:
        result = result
            .where((c) => c.documentationType == DocumentationType.electronic)
            .toList();
      case ClientFilter.paper:
        result = result
            .where((c) => c.documentationType == DocumentationType.paper)
            .toList();
      case ClientFilter.office:
        result =
            result.where((c) => c.clientType == ClientType.office).toList();
      case ClientFilter.private:
        result =
            result.where((c) => c.clientType == ClientType.private).toList();
      case ClientFilter.all:
        break;
    }
    if (_searchQuery.isEmpty) return result;
    return result
        .where(
          (c) =>
              c.fullName.toLowerCase().contains(_searchQuery) ||
              c.phone.contains(_searchQuery),
        )
        .toList();
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
