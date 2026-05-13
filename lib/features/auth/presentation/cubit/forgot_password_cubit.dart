// lib/features/auth/presentation/cubit/forgot_password_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/send_password_reset_email_use_case.dart';
import 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit(this._sendReset) : super(const ForgotPasswordInitial());

  final SendPasswordResetEmailUseCase _sendReset;

  Future<void> sendReset({required String email}) async {
    emit(const ForgotPasswordLoading());
    final result = await _sendReset(SendPasswordResetParams(email: email));
    result.fold(
      (failure) => emit(ForgotPasswordFailure(failure.message)),
      (_) => emit(const ForgotPasswordEmailSent()),
    );
  }
}
