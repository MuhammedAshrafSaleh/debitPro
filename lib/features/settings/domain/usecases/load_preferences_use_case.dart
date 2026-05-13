// lib/features/settings/domain/usecases/load_preferences_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/settings_repository.dart';

class LoadPreferencesUseCase {
  LoadPreferencesUseCase(this._repository);

  final SettingsRepository _repository;

  Future<Either<Failure, Map<String, dynamic>>> call(String uid) =>
      _repository.loadPreferences(uid);
}
