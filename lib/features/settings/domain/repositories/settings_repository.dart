// lib/features/settings/domain/repositories/settings_repository.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';

abstract class SettingsRepository {
  Future<Either<Failure, Map<String, dynamic>>> loadPreferences(String uid);
  Future<Either<Failure, void>> saveLanguage({
    required String uid,
    required String languageCode,
  });
  Future<Either<Failure, void>> saveDarkMode({
    required String uid,
    required bool isDark,
  });
  Future<Either<Failure, void>> updateDisplayName(String displayName);
  Future<Either<Failure, void>> updateEmail({
    required String newEmail,
    required String currentPassword,
  });
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });
}
