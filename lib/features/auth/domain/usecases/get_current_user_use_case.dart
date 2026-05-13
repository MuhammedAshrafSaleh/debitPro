// lib/features/auth/domain/usecases/get_current_user_use_case.dart

import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  GetCurrentUserUseCase(this._repository);
  final AuthRepository _repository;

  AppUser? call() => _repository.currentUser;
}
