// lib/features/accounts/domain/entities/accounts_item.dart

import 'package:equatable/equatable.dart';

import '../../../clients/domain/entities/client_entity.dart';
import '../../../grace_periods/domain/entities/grace_period_entity.dart';
import '../../../installments/domain/entities/payment_entity.dart';

enum AccountsItemKind { installmentPayment, gracePeriod }

/// Unified status used to render summary chips + per-item badges.
enum AccountsItemStatus { upcoming, current, graceWindow, overdue, paid, reversed }

class AccountsItem extends Equatable {
  const AccountsItem({
    required this.id,
    required this.kind,
    required this.clientId,
    required this.clientName,
    required this.clientType,
    required this.itemName,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    required this.status,
    required this.reversed,
    this.payment,
    this.gracePeriod,
  });

  final String id;
  final AccountsItemKind kind;
  final String clientId;
  final String clientName;
  final ClientType clientType;
  final String itemName;
  final double amount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final AccountsItemStatus status;
  final bool reversed;
  final PaymentEntity? payment;
  final GracePeriodEntity? gracePeriod;

  bool get isPaid => status == AccountsItemStatus.paid;

  @override
  List<Object?> get props => [
        id,
        kind,
        clientId,
        clientName,
        clientType,
        itemName,
        amount,
        dueDate,
        paidDate,
        status,
        reversed,
      ];
}

class AccountsSummary extends Equatable {
  const AccountsSummary({
    required this.overdueCount,
    required this.currentCount,
    required this.paidCount,
    required this.totalCollected,
    required this.totalProfits,
    required this.operationsCount,
  });

  final int overdueCount;
  final int currentCount;
  final int paidCount;
  final double totalCollected;
  final double totalProfits;
  final int operationsCount;

  @override
  List<Object?> get props => [
        overdueCount,
        currentCount,
        paidCount,
        totalCollected,
        totalProfits,
        operationsCount,
      ];
}

class OverdueClientInfo extends Equatable {
  const OverdueClientInfo({
    required this.client,
    required this.daysOverdue,
    required this.totalOverdueAmount,
    required this.overdueItemsCount,
  });

  final ClientEntity client;
  final int daysOverdue;
  final double totalOverdueAmount;
  final int overdueItemsCount;

  @override
  List<Object?> get props =>
      [client.id, daysOverdue, totalOverdueAmount, overdueItemsCount];
}

class AccountsList extends Equatable {
  const AccountsList({
    required this.items,
    required this.summary,
    required this.overdueClients,
  });

  final List<AccountsItem> items;
  final AccountsSummary summary;
  final List<OverdueClientInfo> overdueClients;

  @override
  List<Object?> get props => [items, summary, overdueClients];
}

