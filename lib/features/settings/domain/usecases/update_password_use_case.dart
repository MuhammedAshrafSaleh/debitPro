// lib/features/settings/domain/usecases/update_password_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/settings_repository.dart';

class UpdatePasswordParams {
  const UpdatePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });
  final String currentPassword;
  final String newPassword;
}

class UpdatePasswordUseCase {
  UpdatePasswordUseCase(this._repository);

  final SettingsRepository _repository;

  Future<Either<Failure, void>> call(UpdatePasswordParams params) =>
      _repository.updatePassword(
        currentPassword: params.currentPassword,
        newPassword: params.newPassword,
      );
}
