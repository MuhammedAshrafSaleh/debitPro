// lib/features/clients/domain/repositories/client_repository.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/client_entity.dart';

abstract class ClientRepository {
  Stream<List<ClientEntity>> watchClients(ClientFilter filter);

  Future<Either<Failure, ClientEntity>> getClient(String id);

  Future<Either<Failure, ClientEntity>> addClient(AddClientParams params);

  Future<Either<Failure, ClientEntity>> editClient(EditClientParams params);

  Future<Either<Failure, void>> deleteClient(String id);
}

class AddClientParams {
  const AddClientParams({
    required this.fullName,
    required this.phone,
    required this.gender,
    required this.documentationType,
    required this.clientType,
    this.notes,
  });

  final String fullName;
  final String phone;
  final Gender gender;
  final DocumentationType documentationType;
  final ClientType clientType;
  final String? notes;
}

class EditClientParams {
  const EditClientParams({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.gender,
    required this.documentationType,
    required this.clientType,
    this.notes,
  });

  final String id;
  final String fullName;
  final String phone;
  final Gender gender;
  final DocumentationType documentationType;
  final ClientType clientType;
  final String? notes;
}
