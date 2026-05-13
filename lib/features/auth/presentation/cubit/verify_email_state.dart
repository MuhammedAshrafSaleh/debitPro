// lib/features/auth/presentation/cubit/verify_email_state.dart

import 'package:equatable/equatable.dart';

abstract class VerifyEmailState extends Equatable {
  const VerifyEmailState();
  @override
  List<Object?> get props => [];
}

class VerifyEmailInitial extends VerifyEmailState {
  const VerifyEmailInitial();
}

class VerifyEmailResendLoading extends VerifyEmailState {
  const VerifyEmailResendLoading();
}

class VerifyEmailResendSuccess extends VerifyEmailState {
  const VerifyEmailResendSuccess();
}

class VerifyEmailResendFailure extends VerifyEmailState {
  const VerifyEmailResendFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class VerifyEmailVerified extends VerifyEmailState {
  const VerifyEmailVerified();
}
