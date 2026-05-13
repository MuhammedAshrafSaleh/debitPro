// lib/features/auth/domain/usecases/send_password_reset_email_use_case.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SendPasswordResetEmailUseCase
    implements UseCase<void, SendPasswordResetParams> {
  SendPasswordResetEmailUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, void>> call(SendPasswordResetParams params) =>
      _repository.sendPasswordResetEmail(email: params.email);
}

class SendPasswordResetParams extends Equatable {
  const SendPasswordResetParams({required this.email});
  final String email;

  @override
  List<Object?> get props => [email];
}
