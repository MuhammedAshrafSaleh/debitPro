// lib/features/settings/domain/usecases/get_owner_config_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/owner_config_entity.dart';
import '../repositories/settings_repository.dart';

class GetOwnerConfigUseCase {
  const GetOwnerConfigUseCase(this._repository);

  final SettingsRepository _repository;

  Future<Either<Failure, OwnerConfigEntity>> call(String uid) =>
      _repository.getOwnerConfig(uid);
}
