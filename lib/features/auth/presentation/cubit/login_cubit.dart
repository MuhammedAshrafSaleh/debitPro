// lib/features/auth/presentation/cubit/login_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/sign_in_with_email_use_case.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._signIn) : super(const LoginInitial());

  final SignInWithEmailUseCase _signIn;

  Future<void> signIn({required String email, required String password}) async {
    emit(const LoginLoading());
    final result = await _signIn(SignInParams(email: email, password: password));
    result.fold(
      (failure) => emit(LoginFailure(failure.message)),
      (_) => emit(const LoginSuccess()),
    );
  }
}
