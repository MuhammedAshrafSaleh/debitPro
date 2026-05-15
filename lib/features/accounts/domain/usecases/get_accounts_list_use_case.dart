// lib/features/accounts/domain/usecases/get_accounts_list_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/status_utils.dart';
import '../../../clients/domain/entities/client_entity.dart';
import '../../../grace_periods/domain/entities/grace_period_entity.dart';
import '../../../installments/domain/entities/installment_entity.dart';
import '../../../installments/domain/entities/payment_entity.dart';
import '../entities/accounts_filter.dart';
import '../entities/accounts_item.dart';
import '../repositories/accounts_repository.dart';

class GetAccountsListUseCase {
  GetAccountsListUseCase(this._repository);

  final AccountsRepository _repository;

  Future<Either<Failure, AccountsList>> call({
    required AccountsFilter filter,
    required DateTime now,
  }) async {
    final result = await _repository.fetchAccountsData(filter);
    return result.map((raw) => _build(filter: filter, now: now, raw: raw));
  }

  AccountsList _build({
    required AccountsFilter filter,
    required DateTime now,
    required AccountsRawData raw,
  }) {
    final items = <AccountsItem>[];

    if (filter.typeTab != AccountsTypeTab.gracePeriods) {
      for (final p in raw.payments) {
        final client = raw.clientsById[p.clientId];
        if (client == null) continue;
        if (!_passesClientType(client, filter.clientType)) continue;
        final installment = raw.installmentsById[p.installmentId];
        items.add(_itemFromPayment(payment: p, client: client, installment: installment, now: now));
      }
    }

    if (filter.typeTab != AccountsTypeTab.installments) {
      for (final g in raw.gracePeriods) {
        final client = raw.clientsById[g.clientId];
        if (client == null) continue;
        if (!_passesClientType(client, filter.clientType)) continue;
        items.add(_itemFromGracePeriod(gp: g, client: client, now: now));
      }
    }

    final query = filter.searchQuery.trim().toLowerCase();
    final filtered = query.isEmpty
        ? items
        : items
            .where((i) =>
                i.clientName.toLowerCase().contains(query) ||
                i.itemName.toLowerCase().contains(query))
            .toList();

    filtered.sort((a, b) {
      final aDate = a.paidDate ?? a.dueDate;
      final bDate = b.paidDate ?? b.dueDate;
      return bDate.compareTo(aDate);
    });

    final summary = _summary(filtered);
    final overdueClients = _overdueClients(filtered, raw.clientsById, now);

    return AccountsList(
      items: filtered,
      summary: summary,
      overdueClients: overdueClients,
    );
  }

  AccountsItem _itemFromPayment({
    required PaymentEntity payment,
    required ClientEntity client,
    required InstallmentEntity? installment,
    required DateTime now,
  }) {
    final status = _paymentItemStatus(payment, now);
    return AccountsItem(
      id: payment.id,
      kind: AccountsItemKind.installmentPayment,
      clientId: client.id,
      clientName: client.fullName,
      clientType: client.clientType,
      itemName: installment?.itemName ?? '',
      amount: payment.amount,
      dueDate: payment.dueDate,
      paidDate: payment.paidDate,
      status: status,
      reversed: payment.status == PaymentStatus.reversed,
      payment: payment,
    );
  }

  AccountsItem _itemFromGracePeriod({
    required GracePeriodEntity gp,
    required ClientEntity client,
    required DateTime now,
  }) {
    final status = _gracePeriodItemStatus(gp, now);
    return AccountsItem(
      id: gp.id,
      kind: AccountsItemKind.gracePeriod,
      clientId: client.id,
      clientName: client.fullName,
      clientType: client.clientType,
      itemName: gp.name,
      amount: gp.capital,
      dueDate: gp.dueDate,
      paidDate: gp.paidDate,
      status: status,
      reversed: false,
      gracePeriod: gp,
    );
  }

  AccountsItemStatus _paymentItemStatus(PaymentEntity p, DateTime now) {
    if (p.status == PaymentStatus.reversed) return AccountsItemStatus.reversed;
    if (p.status == PaymentStatus.paid) return AccountsItemStatus.paid;
    final computed = StatusUtils.computeInstallmentPaymentStatus(p.dueDate, now);
    switch (computed) {
      case PaymentStatus.upcoming:
        return AccountsItemStatus.upcoming;
      case PaymentStatus.current:
        return AccountsItemStatus.current;
      case PaymentStatus.overdue:
        return AccountsItemStatus.overdue;
      case PaymentStatus.paid:
        return AccountsItemStatus.paid;
      case PaymentStatus.reversed:
        return AccountsItemStatus.reversed;
    }
  }

  AccountsItemStatus _gracePeriodItemStatus(
    GracePeriodEntity g,
    DateTime now,
  ) {
    if (g.status == GracePeriodStatus.paid) return AccountsItemStatus.paid;
    final computed = StatusUtils.computeGracePeriodStatus(g.dueDate, now);
    switch (computed) {
      case GracePeriodStatus.upcoming:
        return AccountsItemStatus.upcoming;
      case GracePeriodStatus.graceWindow:
        return AccountsItemStatus.graceWindow;
      case GracePeriodStatus.overdue:
        return AccountsItemStatus.overdue;
      case GracePeriodStatus.paid:
        return AccountsItemStatus.paid;
    }
  }

  bool _passesClientType(ClientEntity client, AccountsClientType filter) {
    switch (filter) {
      case AccountsClientType.all:
        return true;
      case AccountsClientType.office:
        return client.clientType == ClientType.office;
      case AccountsClientType.private:
        return client.clientType == ClientType.private;
    }
  }

  AccountsSummary _summary(List<AccountsItem> items) {
    var overdue = 0;
    var current = 0;
    var paid = 0;
    var collected = 0.0;
    var profits = 0.0;
    var ops = 0;

    for (final i in items) {
      switch (i.status) {
        case AccountsItemStatus.overdue:
          overdue++;
          break;
        case AccountsItemStatus.current:
        case AccountsItemStatus.graceWindow:
        case AccountsItemStatus.upcoming:
          current++;
          break;
        case AccountsItemStatus.paid:
          paid++;
          break;
        case AccountsItemStatus.reversed:
          break;
      }
      if (i.status == AccountsItemStatus.paid) {
        collected += i.amount;
        if (i.kind == AccountsItemKind.installmentPayment &&
            i.payment != null) {
          profits += i.payment!.profitPortion;
        }
        ops++;
      }
    }

    return AccountsSummary(
      overdueCount: overdue,
      currentCount: current,
      paidCount: paid,
      totalCollected: collected,
      totalProfits: profits,
      operationsCount: ops,
    );
  }

  List<OverdueClientInfo> _overdueClients(
    List<AccountsItem> items,
    Map<String, ClientEntity> clientsById,
    DateTime now,
  ) {
    final grouped = <String, List<AccountsItem>>{};
    for (final i in items) {
      if (i.status != AccountsItemStatus.overdue) continue;
      grouped.putIfAbsent(i.clientId, () => []).add(i);
    }
    final infos = <OverdueClientInfo>[];
    grouped.forEach((clientId, overdueItems) {
      final client = clientsById[clientId];
      if (client == null) return;
      final oldest = overdueItems
          .map((e) => e.dueDate)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      final daysOverdue = AppDateUtils.daysBetween(oldest, now);
      final total = overdueItems.fold<double>(0, (s, i) => s + i.amount);
      infos.add(OverdueClientInfo(
        client: client,
        daysOverdue: daysOverdue,
        totalOverdueAmount: total,
        overdueItemsCount: overdueItems.length,
      ));
    });
    infos.sort((a, b) => b.daysOverdue.compareTo(a.daysOverdue));
    return infos;
  }
}
