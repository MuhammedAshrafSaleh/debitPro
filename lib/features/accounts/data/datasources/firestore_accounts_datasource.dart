// lib/features/accounts/data/datasources/firestore_accounts_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../clients/data/models/client_model.dart';
import '../../../clients/domain/entities/client_entity.dart';
import '../../../grace_periods/data/models/grace_period_model.dart';
import '../../../installments/data/models/installment_model.dart';
import '../../../installments/data/models/payment_model.dart';
import '../../../payments/data/models/transaction_model.dart';
import '../../../payments/domain/entities/transaction_entity.dart';
import '../../domain/entities/accounts_filter.dart';
import '../../domain/entities/pdf_transaction_row.dart';
import '../../domain/repositories/accounts_repository.dart';

abstract class AccountsRemoteDataSource {
  Future<AccountsRawData> fetchAccountsData(AccountsFilter filter);
  Future<List<PdfTransactionRow>> fetchTransactionsPdf(AccountsFilter filter);
}

class AccountsRemoteDataSourceImpl implements AccountsRemoteDataSource {
  AccountsRemoteDataSourceImpl(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final _log = Logger();

  String get _uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _paymentsRef =>
      _firestore.collection(FirestorePaths.payments(_uid));

  CollectionReference<Map<String, dynamic>> get _gracePeriodsRef =>
      _firestore.collection(FirestorePaths.gracePeriods(_uid));

  CollectionReference<Map<String, dynamic>> get _installmentsRef =>
      _firestore.collection(FirestorePaths.installments(_uid));

  CollectionReference<Map<String, dynamic>> get _clientsRef =>
      _firestore.collection(FirestorePaths.clients(_uid));

  CollectionReference<Map<String, dynamic>> get _transactionsRef =>
      _firestore.collection(FirestorePaths.transactions(_uid));

  @override
  Future<AccountsRawData> fetchAccountsData(AccountsFilter filter) async {
    try {
      final fromYm = filter.fromMonth != null
          ? AppDateUtils.yearMonthKey(filter.fromMonth!)
          : null;
      final toYm = filter.toMonth != null
          ? AppDateUtils.yearMonthKey(filter.toMonth!)
          : null;

      final payments = filter.typeTab == AccountsTypeTab.gracePeriods
          ? <PaymentModel>[]
          : await _fetchPayments(fromYm, toYm);

      final gracePeriods = filter.typeTab == AccountsTypeTab.installments
          ? <GracePeriodModel>[]
          : await _fetchGracePeriods(filter.fromMonth, filter.toMonth);

      final installmentIds =
          payments.map((p) => p.installmentId).toSet().toList();
      final installmentsById = await _fetchInstallments(installmentIds);

      final clientIds = <String>{
        ...payments.map((p) => p.clientId),
        ...gracePeriods.map((g) => g.clientId),
      }.toList();
      final clientsById = await _fetchClients(clientIds);

      return AccountsRawData(
        payments: payments,
        gracePeriods: gracePeriods,
        installmentsById: installmentsById,
        clientsById: clientsById,
      );
    } catch (e) {
      _log.e('fetchAccountsData', error: e);
      throw ServerException(e.toString());
    }
  }

  Future<List<PaymentModel>> _fetchPayments(
    String? fromYm,
    String? toYm,
  ) async {
    Query<Map<String, dynamic>> q = _paymentsRef;
    if (fromYm != null) {
      q = q.where('dueMonth', isGreaterThanOrEqualTo: fromYm);
    }
    if (toYm != null) {
      q = q.where('dueMonth', isLessThanOrEqualTo: toYm);
    }
    q = q.orderBy('dueMonth', descending: true).limit(500);
    final snap = await q.get();
    return snap.docs.map(PaymentModel.fromFirestore).toList();
  }

  Future<List<GracePeriodModel>> _fetchGracePeriods(
    DateTime? from,
    DateTime? to,
  ) async {
    Query<Map<String, dynamic>> q = _gracePeriodsRef;
    if (from != null) {
      q = q.where(
        'dueDate',
        isGreaterThanOrEqualTo: Timestamp.fromDate(
          DateTime(from.year, from.month, 1),
        ),
      );
    }
    if (to != null) {
      // Use last day of the toMonth.
      final lastDay = DateTime(to.year, to.month + 1, 0, 23, 59, 59);
      q = q.where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(lastDay));
    }
    q = q.orderBy('dueDate', descending: true).limit(500);
    final snap = await q.get();
    return snap.docs.map(GracePeriodModel.fromFirestore).toList();
  }

  Future<Map<String, InstallmentModel>> _fetchInstallments(
    List<String> ids,
  ) async {
    if (ids.isEmpty) return <String, InstallmentModel>{};
    final map = <String, InstallmentModel>{};
    for (final chunk in _chunked(ids, 10)) {
      final snap =
          await _installmentsRef.where(FieldPath.documentId, whereIn: chunk).get();
      for (final doc in snap.docs) {
        map[doc.id] = InstallmentModel.fromFirestore(doc);
      }
    }
    return map;
  }

  Future<Map<String, ClientModel>> _fetchClients(List<String> ids) async {
    if (ids.isEmpty) return <String, ClientModel>{};
    final map = <String, ClientModel>{};
    for (final chunk in _chunked(ids, 10)) {
      final snap =
          await _clientsRef.where(FieldPath.documentId, whereIn: chunk).get();
      for (final doc in snap.docs) {
        map[doc.id] = ClientModel.fromFirestore(doc);
      }
    }
    return map;
  }

  @override
  Future<List<PdfTransactionRow>> fetchTransactionsPdf(
    AccountsFilter filter,
  ) async {
    try {
      final fromYm = filter.fromMonth != null
          ? AppDateUtils.yearMonthKey(filter.fromMonth!)
          : null;
      final toYm = filter.toMonth != null
          ? AppDateUtils.yearMonthKey(filter.toMonth!)
          : null;

      Query<Map<String, dynamic>> q = _transactionsRef;
      if (fromYm != null) {
        q = q.where('yearMonth', isGreaterThanOrEqualTo: fromYm);
      }
      if (toYm != null) {
        q = q.where('yearMonth', isLessThanOrEqualTo: toYm);
      }
      q = q.orderBy('yearMonth', descending: true).limit(500);

      final snap = await q.get();
      var txs = snap.docs.map(TransactionModel.fromFirestore).toList();

      // Filter by typeTab in Dart (avoids composite index requirement)
      txs = switch (filter.typeTab) {
        AccountsTypeTab.all => txs,
        AccountsTypeTab.installments =>
          txs.where((t) => t.installmentId != null).toList(),
        AccountsTypeTab.gracePeriods =>
          txs.where((t) => t.gracePeriodId != null).toList(),
      };

      // Enrich: clients
      final clientIds = txs.map((t) => t.clientId).toSet().toList();
      final clientsById = await _fetchClients(clientIds);

      // Filter by clientType
      if (filter.clientType != AccountsClientType.all) {
        final wanted = filter.clientType == AccountsClientType.office
            ? ClientType.office
            : ClientType.private;
        txs = txs
            .where((t) => clientsById[t.clientId]?.clientType == wanted)
            .toList();
      }

      // Enrich: installments (for itemName)
      final installmentIds = txs
          .where((t) => t.installmentId != null)
          .map((t) => t.installmentId!)
          .toSet()
          .toList();
      final installmentsById = await _fetchInstallments(installmentIds);

      // Enrich: grace periods (for itemName)
      final gracePeriodIds = txs
          .where((t) => t.gracePeriodId != null)
          .map((t) => t.gracePeriodId!)
          .toSet()
          .toList();
      final gracePeriodsById = await _fetchGracePeriodsById(gracePeriodIds);

      return txs.map((t) {
        final clientName = clientsById[t.clientId]?.fullName ?? '';

        String itemName;
        if (t.installmentId != null) {
          final base = installmentsById[t.installmentId!]?.itemName ?? '';
          itemName = t.relatedType == RelatedType.officeCommission
              ? '$base (عمولة)'
              : base;
        } else if (t.gracePeriodId != null) {
          final base = gracePeriodsById[t.gracePeriodId!]?.name ?? '';
          itemName = t.relatedType == RelatedType.officeCommission
              ? '$base (عمولة)'
              : base;
        } else {
          itemName = '';
        }

        return PdfTransactionRow(
          clientName: clientName,
          itemName: itemName,
          relatedType: t.relatedType,
          paidDate: t.paidDate,
          amount: t.amount,
          status: t.status,
          profitPortion: t.profitPortion,
        );
      }).toList();
    } catch (e) {
      _log.e('fetchTransactionsPdf', error: e);
      throw ServerException(e.toString());
    }
  }

  Future<Map<String, GracePeriodModel>> _fetchGracePeriodsById(
    List<String> ids,
  ) async {
    if (ids.isEmpty) return <String, GracePeriodModel>{};
    final map = <String, GracePeriodModel>{};
    for (final chunk in _chunked(ids, 10)) {
      final snap = await _gracePeriodsRef
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      for (final doc in snap.docs) {
        map[doc.id] = GracePeriodModel.fromFirestore(doc);
      }
    }
    return map;
  }

  Iterable<List<T>> _chunked<T>(List<T> list, int size) sync* {
    for (var i = 0; i < list.length; i += size) {
      yield list.sublist(i, i + size > list.length ? list.length : i + size);
    }
  }
}
