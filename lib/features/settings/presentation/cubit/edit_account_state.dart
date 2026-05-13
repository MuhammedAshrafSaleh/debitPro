// lib/features/settings/presentation/cubit/edit_account_state.dart

import 'package:equatable/equatable.dart';

enum EditAccountSuccessType { displayName, email, password }

enum EditAccountErrorCode {
  emptyDisplayName,
  emptyEmail,
  emptyCurrentPasswordForEmail,
  emptyCurrentPassword,
  shortNewPassword,
  passwordMismatch,
}

abstract class EditAccountState extends Equatable {
  const EditAccountState();

  @override
  List<Object?> get props => [];
}

class EditAccountInitial extends EditAccountState {
  const EditAccountInitial();
}

class EditAccountLoading extends EditAccountState {
  const EditAccountLoading();
}

class EditAccountSuccess extends EditAccountState {
  const EditAccountSuccess(this.type);
  final EditAccountSuccessType type;

  @override
  List<Object?> get props => [type];
}

class EditAccountFailure extends EditAccountState {
  const EditAccountFailure({this.code, this.serverMessage});
  final EditAccountErrorCode? code;
  final String? serverMessage;

  @override
  List<Object?> get props => [code, serverMessage];
}
