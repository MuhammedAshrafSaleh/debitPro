// lib/features/auth/presentation/cubit/forgot_password_state.dart

import 'package:equatable/equatable.dart';

abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();
  @override
  List<Object?> get props => [];
}

class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

class ForgotPasswordLoading extends ForgotPasswordState {
  const ForgotPasswordLoading();
}

class ForgotPasswordEmailSent extends ForgotPasswordState {
  const ForgotPasswordEmailSent();
}

class ForgotPasswordFailure extends ForgotPasswordState {
  const ForgotPasswordFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
