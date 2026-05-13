// lib/features/settings/domain/usecases/toggle_theme_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/settings_repository.dart';

class ThemeParams {
  const ThemeParams({required this.uid, required this.isDark});
  final String uid;
  final bool isDark;
}

class ToggleThemeUseCase {
  ToggleThemeUseCase(this._repository);

  final SettingsRepository _repository;

  Future<Either<Failure, void>> call(ThemeParams params) =>
      _repository.saveDarkMode(uid: params.uid, isDark: params.isDark);
}
