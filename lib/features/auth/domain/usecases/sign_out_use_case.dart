// lib/features/auth/domain/usecases/sign_out_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SignOutUseCase implements UseCase<void, NoParams> {
  SignOutUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) =>
      _repository.signOut();
}
