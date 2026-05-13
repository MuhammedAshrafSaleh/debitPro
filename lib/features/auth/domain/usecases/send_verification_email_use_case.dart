// lib/features/auth/domain/usecases/send_verification_email_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SendVerificationEmailUseCase implements UseCase<void, NoParams> {
  SendVerificationEmailUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) =>
      _repository.sendVerificationEmail();
}
