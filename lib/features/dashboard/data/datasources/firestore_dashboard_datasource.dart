// lib/features/dashboard/data/datasources/firestore_dashboard_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../payments/data/models/transaction_model.dart';
import '../models/dashboard_aggregates.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardAggregates> fetchAggregates(DateTime now);
  Future<List<TransactionModel>> fetchRecentTransactions(int limit);
  Future<Map<String, String>> fetchClientNames(List<String> clientIds);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  DashboardRemoteDataSourceImpl(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final _log = Logger();

  String get _uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _paymentsRef =>
      _firestore.collection(FirestorePaths.payments(_uid));

  CollectionReference<Map<String, dynamic>> get _gracePeriodsRef =>
      _firestore.collection(FirestorePaths.gracePeriods(_uid));

  CollectionReference<Map<String, dynamic>> get _transactionsRef =>
      _firestore.collection(FirestorePaths.transactions(_uid));

  CollectionReference<Map<String, dynamic>> get _clientsRef =>
      _firestore.collection(FirestorePaths.clients(_uid));

  DocumentReference<Map<String, dynamic>> get _allTimeRef =>
      _firestore.doc(FirestorePaths.allTimeAgg(_uid));

  DocumentReference<Map<String, dynamic>> _monthlyRef(String yearMonth) =>
      _firestore.doc(FirestorePaths.monthlyAgg(_uid, yearMonth));

  @override
  Future<DashboardAggregates> fetchAggregates(DateTime now) async {
    try {
      final yearMonth = AppDateUtils.yearMonthKey(now);
      final firstDay = AppDateUtils.firstDayOfMonth(now);
      final lastDay = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      // Run aggregates + target queries in parallel.
      final results = await Future.wait<dynamic>([
        _monthlyRef(yearMonth).get(),
        _allTimeRef.get(),
        _paymentsRef.where('dueMonth', isEqualTo: yearMonth).get(),
        _gracePeriodsRef
            .where('dueDate',
                isGreaterThanOrEqualTo: Timestamp.fromDate(firstDay))
            .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(lastDay))
            .get(),
      ]);

      final monthlyDoc =
          results[0] as DocumentSnapshot<Map<String, dynamic>>;
      final allTimeDoc =
          results[1] as DocumentSnapshot<Map<String, dynamic>>;
      final paymentsSnap =
          results[2] as QuerySnapshot<Map<String, dynamic>>;
      final graceSnap =
          results[3] as QuerySnapshot<Map<String, dynamic>>;

      final monthlyData = monthlyDoc.data() ?? const <String, dynamic>{};
      final allTimeData = allTimeDoc.data() ?? const <String, dynamic>{};

      final monthlyCollection =
          (monthlyData['monthlyCollection'] as num?)?.toDouble() ?? 0;

      var monthlyTarget = 0.0;
      for (final doc in paymentsSnap.docs) {
        monthlyTarget += (doc.data()['amount'] as num?)?.toDouble() ?? 0;
      }
      for (final doc in graceSnap.docs) {
        monthlyTarget += (doc.data()['capital'] as num?)?.toDouble() ?? 0;
      }

      return DashboardAggregates(
        monthlyCollection: monthlyCollection,
        monthlyTarget: monthlyTarget,
        totalProfits:
            (allTimeData['totalRecognizedProfit'] as num?)?.toDouble() ?? 0,
        totalCapital:
            (allTimeData['totalCapital'] as num?)?.toDouble() ?? 0,
        totalOfficeCommission:
            (allTimeData['totalOfficeCommission'] as num?)?.toDouble() ?? 0,
        totalClients: ((allTimeData['totalClients'] as num?) ?? 0).toInt(),
      );
    } catch (e) {
      _log.e('fetchAggregates', error: e);
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<TransactionModel>> fetchRecentTransactions(int limit) async {
    try {
      // Filter `status == completed` client-side to avoid needing a
      // (status, createdAt) composite index. Fetch a buffer of extra docs
      // so reversed transactions don't shrink the page below `limit`.
      final snap = await _transactionsRef
          .orderBy('createdAt', descending: true)
          .limit(limit * 3)
          .get();
      return snap.docs
          .where((d) => d.data()['status'] == 'completed')
          .take(limit)
          .map(TransactionModel.fromFirestore)
          .toList();
    } catch (e) {
      _log.e('fetchRecentTransactions', error: e);
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, String>> fetchClientNames(List<String> clientIds) async {
    if (clientIds.isEmpty) return <String, String>{};
    try {
      final map = <String, String>{};
      for (final chunk in _chunked(clientIds.toSet().toList(), 10)) {
        final snap = await _clientsRef
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        for (final doc in snap.docs) {
          map[doc.id] = (doc.data()['fullName'] as String?) ?? '';
        }
      }
      return map;
    } catch (e) {
      _log.e('fetchClientNames', error: e);
      throw ServerException(e.toString());
    }
  }

  Iterable<List<T>> _chunked<T>(List<T> list, int size) sync* {
    for (var i = 0; i < list.length; i += size) {
      yield list.sublist(i, i + size > list.length ? list.length : i + size);
    }
  }
}
