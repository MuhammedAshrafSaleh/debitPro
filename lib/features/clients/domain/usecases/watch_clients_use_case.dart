// lib/features/clients/domain/usecases/watch_clients_use_case.dart

import '../../domain/entities/client_entity.dart';
import '../../domain/repositories/client_repository.dart';

class WatchClientsUseCase {
  WatchClientsUseCase(this._repository);

  final ClientRepository _repository;

  Stream<List<ClientEntity>> call(ClientFilter filter) =>
      _repository.watchClients(filter);
}
