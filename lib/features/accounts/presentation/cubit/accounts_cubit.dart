// lib/features/accounts/presentation/cubit/accounts_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/accounts_filter.dart';
import '../../domain/usecases/get_accounts_list_use_case.dart';
import 'accounts_state.dart';

class AccountsCubit extends Cubit<AccountsState> {
  AccountsCubit(this._getAccountsList) : super(const AccountsState());

  final GetAccountsListUseCase _getAccountsList;

  Future<void> load({AccountsFilter? filter}) async {
    final effectiveFilter = filter ?? state.filter;
    emit(state.copyWith(
      status: AccountsStatus.loading,
      filter: effectiveFilter,
      clearFailure: true,
    ));
    final result = await _getAccountsList(
      filter: effectiveFilter,
      now: DateTime.now(),
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(
        status: AccountsStatus.failure,
        failureMessage: failure.message,
      )),
      (data) => emit(state.copyWith(
        status: AccountsStatus.loaded,
        data: data,
      )),
    );
  }

  void setTypeTab(AccountsTypeTab tab) {
    if (state.filter.typeTab == tab) return;
    load(filter: state.filter.copyWith(typeTab: tab));
  }

  void setClientType(AccountsClientType type) {
    if (state.filter.clientType == type) return;
    load(filter: state.filter.copyWith(clientType: type));
  }

  void setFromMonth(DateTime? from) {
    load(filter: state.filter.copyWith(
      fromMonth: from,
      clearFromMonth: from == null,
    ));
  }

  void setToMonth(DateTime? to) {
    load(filter: state.filter.copyWith(
      toMonth: to,
      clearToMonth: to == null,
    ));
  }

  void setSearchQuery(String query) {
    load(filter: state.filter.copyWith(searchQuery: query));
  }

  Future<void> refresh() => load();
}
