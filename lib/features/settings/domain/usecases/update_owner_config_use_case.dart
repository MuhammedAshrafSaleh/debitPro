// lib/features/settings/domain/usecases/update_owner_config_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/settings_repository.dart';

class UpdateOwnerConfigParams {
  const UpdateOwnerConfigParams({
    required this.uid,
    required this.cardFee,
    required this.riyalValue,
  });

  final String uid;
  final double cardFee;
  final double riyalValue;
}

class UpdateOwnerConfigUseCase {
  const UpdateOwnerConfigUseCase(this._repository);

  final SettingsRepository _repository;

  Future<Either<Failure, void>> call(UpdateOwnerConfigParams params) =>
      _repository.updateOwnerConfig(
        uid: params.uid,
        cardFee: params.cardFee,
        riyalValue: params.riyalValue,
      );
}
