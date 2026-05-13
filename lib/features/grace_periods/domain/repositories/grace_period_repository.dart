// lib/features/grace_periods/domain/repositories/grace_period_repository.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../features/clients/domain/entities/client_entity.dart';
import '../entities/grace_period_entity.dart';

abstract class GracePeriodRepository {
  Stream<List<GracePeriodEntity>> watchGracePeriodsForClient(String clientId);

  Future<Either<Failure, GracePeriodEntity>> getGracePeriod(String gracePeriodId);

  Future<Either<Failure, GracePeriodEntity>> addGracePeriod(
    AddGracePeriodParams params,
  );

  Future<Either<Failure, GracePeriodEntity>> editGracePeriod(
    EditGracePeriodParams params,
  );

  Future<Either<Failure, void>> payOfficeCommission(String gracePeriodId);

  Future<Either<Failure, void>> payGracePeriod(String gracePeriodId);
}

class AddGracePeriodParams {
  const AddGracePeriodParams({
    required this.clientId,
    required this.clientType,
    required this.officeCommissionPaidAtCreation,
    required this.name,
    required this.capital,
    required this.dueDate,
    this.notes,
  });

  final String clientId;
  final ClientType clientType;
  final bool officeCommissionPaidAtCreation;
  final String name;
  final double capital;
  final DateTime dueDate;
  final String? notes;
}

class EditGracePeriodParams {
  const EditGracePeriodParams({
    required this.id,
    required this.clientId,
    required this.name,
    required this.capital,
    required this.dueDate,
    this.notes,
  });

  final String id;
  final String clientId;
  final String name;
  final double capital;
  final DateTime dueDate;
  final String? notes;
}
