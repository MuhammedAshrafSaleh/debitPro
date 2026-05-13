// lib/features/auth/domain/usecases/register_use_case.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase implements UseCase<AppUser, RegisterParams> {
  RegisterUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, AppUser>> call(RegisterParams params) =>
      _repository.register(
        displayName: params.displayName,
        email: params.email,
        password: params.password,
      );
}

class RegisterParams extends Equatable {
  const RegisterParams({
    required this.displayName,
    required this.email,
    required this.password,
  });
  final String displayName;
  final String email;
  final String password;

  @override
  List<Object?> get props => [displayName, email, password];
}
