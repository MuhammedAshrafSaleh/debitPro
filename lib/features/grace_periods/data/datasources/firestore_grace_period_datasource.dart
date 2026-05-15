// lib/features/grace_periods/data/datasources/firestore_grace_period_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/status_utils.dart';
import '../../../../features/clients/domain/entities/client_entity.dart';
import '../../data/models/grace_period_model.dart';
import '../../domain/repositories/grace_period_repository.dart';

abstract class GracePeriodRemoteDataSource {
  Stream<List<GracePeriodModel>> watchGracePeriodsForClient(String clientId);

  Future<GracePeriodModel> getGracePeriod(String gracePeriodId);

  Future<GracePeriodModel> addGracePeriod(AddGracePeriodParams params);

  Future<GracePeriodModel> editGracePeriod(EditGracePeriodParams params);

  Future<void> payOfficeCommission(String gracePeriodId);
}

class GracePeriodRemoteDataSourceImpl implements GracePeriodRemoteDataSource {
  GracePeriodRemoteDataSourceImpl(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final _log = Logger();

  String get _uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _gracePeriodsRef =>
      _firestore.collection(FirestorePaths.gracePeriods(_uid));

  CollectionReference<Map<String, dynamic>> get _transactionsRef =>
      _firestore.collection(FirestorePaths.transactions(_uid));

  DocumentReference<Map<String, dynamic>> get _allTimeRef =>
      _firestore.doc(FirestorePaths.allTimeAgg(_uid));

  DocumentReference<Map<String, dynamic>> _clientRef(String clientId) =>
      _firestore.doc(FirestorePaths.client(_uid, clientId));

  @override
  Stream<List<GracePeriodModel>> watchGracePeriodsForClient(String clientId) {
    return _gracePeriodsRef
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .limit(200)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => GracePeriodModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<GracePeriodModel> getGracePeriod(String gracePeriodId) async {
    try {
      final doc = await _gracePeriodsRef.doc(gracePeriodId).get();
      if (!doc.exists) throw ServerException('المهلة غير موجودة');
      return GracePeriodModel.fromFirestore(doc);
    } catch (e) {
      _log.e('getGracePeriod', error: e);
      throw ServerException(e.toString());
    }
  }

  @override
  Future<GracePeriodModel> addGracePeriod(AddGracePeriodParams params) async {
    try {
      final isOffice = params.clientType == ClientType.office;
      final officeCommissionAmount =
          isOffice ? params.capital * AppConstants.kOfficeCommissionRate : 0.0;
      final gracePeriodEndDate = params.dueDate
          .add(const Duration(days: AppConstants.kGraceWindowDays));
      final now = DateTime.now();
      final officeCommissionPaid =
          isOffice && params.officeCommissionPaidAtCreation;

      final status =
          StatusUtils.computeGracePeriodStatus(params.dueDate, now);

      final gpRef = _gracePeriodsRef.doc();
      final model = GracePeriodModel(
        id: gpRef.id,
        clientId: params.clientId,
        name: params.name,
        capital: params.capital,
        notes: params.notes,
        dueDate: params.dueDate,
        gracePeriodEndDate: gracePeriodEndDate,
        officeCommissionAmount: officeCommissionAmount,
        officeCommissionPaid: officeCommissionPaid,
        officeCommissionPaidAt: officeCommissionPaid ? now : null,
        status: status,
        paidDate: null,
        paidAt: null,
        editLocked: false,
        createdAt: now,
        updatedAt: now,
      );

      final batch = _firestore.batch();

      batch.set(gpRef, model.toFirestore());

      batch.set(
        _clientRef(params.clientId),
        {
          'totalRemaining': FieldValue.increment(params.capital),
          'activeDebtsCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      batch.set(
        _allTimeRef,
        {
          'totalCapital': FieldValue.increment(params.capital),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (officeCommissionPaid) {
        final txRef = _transactionsRef.doc();
        batch.set(txRef, {
          'clientId': params.clientId,
          'relatedId': gpRef.id,
          'relatedType': 'office_commission',
          'installmentId': null,
          'gracePeriodId': gpRef.id,
          'amount': officeCommissionAmount,
          'profitPortion': null,
          'type': 'office_commission',
          'status': 'completed',
          'yearMonth': AppDateUtils.yearMonthKey(now),
          'paidDate': Timestamp.fromDate(now),
          'reversedAt': null,
          'reversalNote': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
        batch.set(
          _allTimeRef,
          {
            'totalOfficeCommission': FieldValue.increment(officeCommissionAmount),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      await batch.commit();
      return model;
    } catch (e) {
      _log.e('addGracePeriod', error: e);
      throw ServerException(e.toString());
    }
  }

  // 9.5 — editLocked check is done in repo impl before reaching here
  @override
  Future<GracePeriodModel> editGracePeriod(EditGracePeriodParams params) async {
    try {
      final gracePeriodEndDate = params.dueDate
          .add(const Duration(days: AppConstants.kGraceWindowDays));
      final now = DateTime.now();
      final status =
          StatusUtils.computeGracePeriodStatus(params.dueDate, now);

      final oldDoc = await _gracePeriodsRef.doc(params.id).get();
      if (!oldDoc.exists) throw ServerException('المهلة غير موجودة');
      final oldModel = GracePeriodModel.fromFirestore(oldDoc);
      final diff = params.capital - oldModel.capital;

      final batch = _firestore.batch();

      batch.update(_gracePeriodsRef.doc(params.id), {
        'name': params.name,
        'capital': params.capital,
        'notes': params.notes,
        'dueDate': Timestamp.fromDate(params.dueDate),
        'gracePeriodEndDate': Timestamp.fromDate(gracePeriodEndDate),
        'status': _statusToString(status),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (diff != 0) {
        batch.set(
          _clientRef(params.clientId),
          {
            'totalRemaining': FieldValue.increment(diff),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
        batch.set(
          _allTimeRef,
          {
            'totalCapital': FieldValue.increment(diff),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      await batch.commit();

      final updatedDoc = await _gracePeriodsRef.doc(params.id).get();
      return GracePeriodModel.fromFirestore(updatedDoc);
    } catch (e) {
      _log.e('editGracePeriod', error: e);
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> payOfficeCommission(String gracePeriodId) async {
    try {
      final uid = _uid;
      final now = DateTime.now();

      final gpDoc = await _gracePeriodsRef.doc(gracePeriodId).get();
      if (!gpDoc.exists) throw ServerException('المهلة غير موجودة');
      final gp = GracePeriodModel.fromFirestore(gpDoc);

      if (gp.officeCommissionPaid) {
        throw ServerException('تم دفع العمولة مسبقاً');
      }

      final txRef = _transactionsRef.doc();

      await _firestore.runTransaction((tx) async {
        tx.update(_gracePeriodsRef.doc(gracePeriodId), {
          'officeCommissionPaid': true,
          'officeCommissionPaidAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        tx.set(txRef, {
          'clientId': gp.clientId,
          'relatedId': gracePeriodId,
          'relatedType': 'office_commission',
          'installmentId': null,
          'gracePeriodId': gracePeriodId,
          'amount': gp.officeCommissionAmount,
          'profitPortion': null,
          'type': 'office_commission',
          'status': 'completed',
          'yearMonth': AppDateUtils.yearMonthKey(now),
          'paidDate': Timestamp.fromDate(now),
          'reversedAt': null,
          'reversalNote': null,
          'createdAt': FieldValue.serverTimestamp(),
        });

        tx.set(
          _firestore.doc(FirestorePaths.allTimeAgg(uid)),
          {
            'totalOfficeCommission':
                FieldValue.increment(gp.officeCommissionAmount),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      });
    } catch (e) {
      _log.e('payOfficeCommission', error: e);
      throw ServerException(e.toString());
    }
  }

  static String _statusToString(GracePeriodStatus status) {
    switch (status) {
      case GracePeriodStatus.graceWindow:
        return 'grace_window';
      case GracePeriodStatus.overdue:
        return 'overdue';
      case GracePeriodStatus.paid:
        return 'paid';
      case GracePeriodStatus.upcoming:
        return 'upcoming';
    }
  }
}
