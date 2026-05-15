// lib/features/auth/presentation/cubit/register_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/register_use_case.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._register) : super(const RegisterInitial());

  final RegisterUseCase _register;

  Future<void> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    emit(const RegisterLoading());
    final result = await _register(
      RegisterParams(displayName: displayName, email: email, password: password),
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(RegisterFailure(failure.message)),
      (_) => emit(const RegisterSuccess()),
    );
  }
}
