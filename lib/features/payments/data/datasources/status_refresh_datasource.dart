// lib/features/payments/data/datasources/status_refresh_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/status_utils.dart';

class StatusRefreshResult {
  const StatusRefreshResult({
    required this.paymentsUpdated,
    required this.gracePeriodsUpdated,
  });

  final int paymentsUpdated;
  final int gracePeriodsUpdated;

  int get total => paymentsUpdated + gracePeriodsUpdated;
}

abstract class StatusRefreshDataSource {
  Future<StatusRefreshResult> refresh(DateTime now);
}

class StatusRefreshDataSourceImpl implements StatusRefreshDataSource {
  StatusRefreshDataSourceImpl(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final _log = Logger();

  String get _uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _paymentsRef =>
      _firestore.collection(FirestorePaths.payments(_uid));

  CollectionReference<Map<String, dynamic>> get _gracePeriodsRef =>
      _firestore.collection(FirestorePaths.gracePeriods(_uid));

  @override
  Future<StatusRefreshResult> refresh(DateTime now) async {
    try {
      final paymentsUpdated = await _refreshPayments(now);
      final gpUpdated = await _refreshGracePeriods(now);
      return StatusRefreshResult(
        paymentsUpdated: paymentsUpdated,
        gracePeriodsUpdated: gpUpdated,
      );
    } catch (e) {
      _log.e('refreshStatuses', error: e);
      throw ServerException(e.toString());
    }
  }

  Future<int> _refreshPayments(DateTime now) async {
    final snap = await _paymentsRef
        .where('status', whereIn: ['upcoming', 'current']).get();

    if (snap.docs.isEmpty) return 0;

    final updates = <(DocumentReference<Map<String, dynamic>>, String)>[];
    for (final doc in snap.docs) {
      final data = doc.data();
      final current = data['status'] as String?;
      final dueDate = (data['dueDate'] as Timestamp?)?.toDate();
      if (dueDate == null) continue;
      final next =
          StatusUtils.computeInstallmentPaymentStatus(dueDate, now).name;
      if (next != current) {
        updates.add((doc.reference, next));
      }
    }

    return _commitInChunks(updates);
  }

  Future<int> _refreshGracePeriods(DateTime now) async {
    final snap = await _gracePeriodsRef
        .where('status', whereIn: ['upcoming', 'grace_window']).get();

    if (snap.docs.isEmpty) return 0;

    final updates = <(DocumentReference<Map<String, dynamic>>, String)>[];
    for (final doc in snap.docs) {
      final data = doc.data();
      final current = data['status'] as String?;
      final dueDate = (data['dueDate'] as Timestamp?)?.toDate();
      if (dueDate == null) continue;
      final next =
          _gracePeriodWire(StatusUtils.computeGracePeriodStatus(dueDate, now));
      if (next != current) {
        updates.add((doc.reference, next));
      }
    }

    return _commitInChunks(updates);
  }

  Future<int> _commitInChunks(
    List<(DocumentReference<Map<String, dynamic>>, String)> updates,
  ) async {
    if (updates.isEmpty) return 0;
    int written = 0;
    for (int i = 0; i < updates.length; i += AppConstants.kBatchLimit) {
      final end = (i + AppConstants.kBatchLimit) > updates.length
          ? updates.length
          : i + AppConstants.kBatchLimit;
      final chunk = updates.sublist(i, end);
      final batch = _firestore.batch();
      for (final (ref, status) in chunk) {
        batch.update(ref, {
          'status': status,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      written += chunk.length;
    }
    return written;
  }

  String _gracePeriodWire(GracePeriodStatus status) => switch (status) {
        GracePeriodStatus.upcoming => 'upcoming',
        GracePeriodStatus.graceWindow => 'grace_window',
        GracePeriodStatus.overdue => 'overdue',
        GracePeriodStatus.paid => 'paid',
      };
}
