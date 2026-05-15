// lib/features/settings/presentation/cubit/edit_account_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/update_display_name_use_case.dart';
import '../../domain/usecases/update_email_use_case.dart';
import '../../domain/usecases/update_password_use_case.dart';
import 'edit_account_state.dart';

class EditAccountCubit extends Cubit<EditAccountState> {
  EditAccountCubit(
    this._updateDisplayName,
    this._updateEmail,
    this._updatePassword,
  ) : super(const EditAccountInitial());

  final UpdateDisplayNameUseCase _updateDisplayName;
  final UpdateEmailUseCase _updateEmail;
  final UpdatePasswordUseCase _updatePassword;

  Future<void> updateDisplayName(String displayName) async {
    if (displayName.trim().isEmpty) {
      emit(const EditAccountFailure(code: EditAccountErrorCode.emptyDisplayName));
      return;
    }
    emit(const EditAccountLoading());
    final result = await _updateDisplayName(displayName.trim());
    if (isClosed) return;
    result.fold(
      (failure) => emit(EditAccountFailure(serverMessage: failure.message)),
      (_) => emit(const EditAccountSuccess(EditAccountSuccessType.displayName)),
    );
  }

  Future<void> updateEmail({
    required String newEmail,
    required String currentPassword,
  }) async {
    if (newEmail.trim().isEmpty) {
      emit(const EditAccountFailure(code: EditAccountErrorCode.emptyEmail));
      return;
    }
    if (currentPassword.isEmpty) {
      emit(const EditAccountFailure(code: EditAccountErrorCode.emptyCurrentPasswordForEmail));
      return;
    }
    emit(const EditAccountLoading());
    final result = await _updateEmail(
      UpdateEmailParams(
        newEmail: newEmail.trim(),
        currentPassword: currentPassword,
      ),
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(EditAccountFailure(serverMessage: failure.message)),
      (_) => emit(const EditAccountSuccess(EditAccountSuccessType.email)),
    );
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (currentPassword.isEmpty) {
      emit(const EditAccountFailure(code: EditAccountErrorCode.emptyCurrentPassword));
      return;
    }
    if (newPassword.length < 8) {
      emit(const EditAccountFailure(code: EditAccountErrorCode.shortNewPassword));
      return;
    }
    if (newPassword != confirmPassword) {
      emit(const EditAccountFailure(code: EditAccountErrorCode.passwordMismatch));
      return;
    }
    emit(const EditAccountLoading());
    final result = await _updatePassword(
      UpdatePasswordParams(
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(EditAccountFailure(serverMessage: failure.message)),
      (_) => emit(const EditAccountSuccess(EditAccountSuccessType.password)),
    );
  }

  void reset() => emit(const EditAccountInitial());
}
