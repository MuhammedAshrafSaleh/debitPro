// lib/features/accounts/presentation/cubit/accounts_state.dart

import 'package:equatable/equatable.dart';

import '../../domain/entities/accounts_filter.dart';
import '../../domain/entities/accounts_item.dart';

enum AccountsStatus { initial, loading, loaded, failure }

class AccountsState extends Equatable {
  const AccountsState({
    this.status = AccountsStatus.initial,
    this.filter = const AccountsFilter(),
    this.data,
    this.failureMessage,
  });

  final AccountsStatus status;
  final AccountsFilter filter;
  final AccountsList? data;
  final String? failureMessage;

  AccountsState copyWith({
    AccountsStatus? status,
    AccountsFilter? filter,
    AccountsList? data,
    String? failureMessage,
    bool clearFailure = false,
  }) {
    return AccountsState(
      status: status ?? this.status,
      filter: filter ?? this.filter,
      data: data ?? this.data,
      failureMessage: clearFailure ? null : (failureMessage ?? this.failureMessage),
    );
  }

  @override
  List<Object?> get props => [status, filter, data, failureMessage];
}
