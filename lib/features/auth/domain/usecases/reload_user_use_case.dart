// lib/features/auth/domain/usecases/reload_user_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class ReloadUserUseCase implements UseCase<AppUser, NoParams> {
  ReloadUserUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, AppUser>> call(NoParams params) =>
      _repository.reloadUser();
}
