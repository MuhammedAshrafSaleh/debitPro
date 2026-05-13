// lib/features/settings/domain/usecases/update_display_name_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/settings_repository.dart';

class UpdateDisplayNameUseCase {
  UpdateDisplayNameUseCase(this._repository);

  final SettingsRepository _repository;

  Future<Either<Failure, void>> call(String displayName) =>
      _repository.updateDisplayName(displayName);
}
