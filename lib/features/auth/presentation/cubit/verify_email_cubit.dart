// lib/features/auth/presentation/cubit/verify_email_cubit.dart

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_current_user_use_case.dart';
import '../../domain/usecases/reload_user_use_case.dart';
import '../../domain/usecases/send_verification_email_use_case.dart';
import '../../domain/usecases/sign_out_use_case.dart';
import 'verify_email_state.dart';

class VerifyEmailCubit extends Cubit<VerifyEmailState> {
  VerifyEmailCubit(
    this._reloadUser,
    this._sendVerification,
    this._signOut,
    this._getCurrentUser,
  ) : super(const VerifyEmailInitial());

  final ReloadUserUseCase _reloadUser;
  final SendVerificationEmailUseCase _sendVerification;
  final SignOutUseCase _signOut;
  final GetCurrentUserUseCase _getCurrentUser;

  Timer? _pollTimer;

  String get currentEmail => _getCurrentUser()?.email ?? '';

  void startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkVerified(),
    );
  }

  Future<void> _checkVerified() async {
    final result = await _reloadUser(NoParams());
    result.fold(
      (_) {},
      (user) {
        if (user.isEmailVerified) {
          _pollTimer?.cancel();
          emit(const VerifyEmailVerified());
        }
      },
    );
  }

  Future<void> checkNow() => _checkVerified();

  Future<void> resend() async {
    emit(const VerifyEmailResendLoading());
    final result = await _sendVerification(NoParams());
    result.fold(
      (failure) => emit(VerifyEmailResendFailure(failure.message)),
      (_) => emit(const VerifyEmailResendSuccess()),
    );
  }

  Future<void> signOut() async {
    _pollTimer?.cancel();
    await _signOut(NoParams());
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }
}
