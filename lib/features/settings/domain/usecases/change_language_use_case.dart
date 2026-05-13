// lib/features/settings/domain/usecases/change_language_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/settings_repository.dart';

class LanguageParams {
  const LanguageParams({required this.uid, required this.languageCode});
  final String uid;
  final String languageCode;
}

class ChangeLanguageUseCase {
  ChangeLanguageUseCase(this._repository);

  final SettingsRepository _repository;

  Future<Either<Failure, void>> call(LanguageParams params) =>
      _repository.saveLanguage(
        uid: params.uid,
        languageCode: params.languageCode,
      );
}
