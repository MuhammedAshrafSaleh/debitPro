// lib/features/accounts/domain/entities/accounts_filter.dart

import 'package:equatable/equatable.dart';

enum AccountsTypeTab { all, installments, gracePeriods }

enum AccountsClientType { all, office, private }

class AccountsFilter extends Equatable {
  const AccountsFilter({
    this.typeTab = AccountsTypeTab.all,
    this.fromMonth,
    this.toMonth,
    this.clientType = AccountsClientType.all,
    this.searchQuery = '',
  });

  final AccountsTypeTab typeTab;
  final DateTime? fromMonth;
  final DateTime? toMonth;
  final AccountsClientType clientType;
  final String searchQuery;

  bool get hasDateRange => fromMonth != null || toMonth != null;

  AccountsFilter copyWith({
    AccountsTypeTab? typeTab,
    DateTime? fromMonth,
    DateTime? toMonth,
    AccountsClientType? clientType,
    String? searchQuery,
    bool clearFromMonth = false,
    bool clearToMonth = false,
  }) {
    return AccountsFilter(
      typeTab: typeTab ?? this.typeTab,
      fromMonth: clearFromMonth ? null : (fromMonth ?? this.fromMonth),
      toMonth: clearToMonth ? null : (toMonth ?? this.toMonth),
      clientType: clientType ?? this.clientType,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [typeTab, fromMonth, toMonth, clientType, searchQuery];
}
