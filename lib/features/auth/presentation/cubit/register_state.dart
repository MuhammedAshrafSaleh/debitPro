// lib/features/auth/presentation/cubit/register_state.dart

import 'package:equatable/equatable.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();
  @override
  List<Object?> get props => [];
}

class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

class RegisterSuccess extends RegisterState {
  const RegisterSuccess();
}

class RegisterFailure extends RegisterState {
  const RegisterFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
