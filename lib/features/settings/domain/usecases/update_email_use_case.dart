// lib/features/settings/domain/usecases/update_email_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/settings_repository.dart';

class UpdateEmailParams {
  const UpdateEmailParams({
    required this.newEmail,
    required this.currentPassword,
  });
  final String newEmail;
  final String currentPassword;
}

class UpdateEmailUseCase {
  UpdateEmailUseCase(this._repository);

  final SettingsRepository _repository;

  Future<Either<Failure, void>> call(UpdateEmailParams params) =>
      _repository.updateEmail(
        newEmail: params.newEmail,
        currentPassword: params.currentPassword,
      );
}
