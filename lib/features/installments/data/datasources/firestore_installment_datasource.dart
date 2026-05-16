// lib/features/installments/data/datasources/firestore_installment_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/status_utils.dart';
import '../../../../features/clients/domain/entities/client_entity.dart';
import '../../data/models/installment_model.dart';
import '../../data/models/payment_model.dart';
import '../../domain/entities/installment_entity.dart';
import '../../domain/repositories/installment_repository.dart';

abstract class InstallmentRemoteDataSource {
  Stream<List<InstallmentModel>> watchInstallmentsForClient(String clientId);

  Future<(InstallmentModel, List<PaymentModel>)> getInstallmentWithPayments(
    String installmentId,
  );

  Future<InstallmentModel> addInstallment(AddInstallmentParams params);

  Future<InstallmentModel> editInstallment(EditInstallmentParams params);

  Future<void> payOfficeCommission(String installmentId);

  Future<void> deleteInstallment(String installmentId);
}

class InstallmentRemoteDataSourceImpl implements InstallmentRemoteDataSource {
  InstallmentRemoteDataSourceImpl(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final _log = Logger();

  String get _uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _installmentsRef =>
      _firestore.collection(FirestorePaths.installments(_uid));

  CollectionReference<Map<String, dynamic>> get _paymentsRef =>
      _firestore.collection(FirestorePaths.payments(_uid));

  CollectionReference<Map<String, dynamic>> get _transactionsRef =>
      _firestore.collection(FirestorePaths.transactions(_uid));

  DocumentReference<Map<String, dynamic>> get _allTimeRef =>
      _firestore.doc(FirestorePaths.allTimeAgg(_uid));

  DocumentReference<Map<String, dynamic>> _clientRef(String clientId) =>
      _firestore.doc(FirestorePaths.client(_uid, clientId));

  @override
  Stream<List<InstallmentModel>> watchInstallmentsForClient(String clientId) {
    return _installmentsRef
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .limit(200)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => InstallmentModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<(InstallmentModel, List<PaymentModel>)> getInstallmentWithPayments(
    String installmentId,
  ) async {
    try {
      final instDoc = await _installmentsRef.doc(installmentId).get();
      if (!instDoc.exists) throw ServerException('القسط غير موجود');

      final paymentsSnap = await _paymentsRef
          .where('installmentId', isEqualTo: installmentId)
          .orderBy('monthIndex')
          .get();

      final installment = InstallmentModel.fromFirestore(instDoc);
      final payments = paymentsSnap.docs
          .map((doc) => PaymentModel.fromFirestore(doc))
          .toList();

      return (installment, payments);
    } on ServerException {
      rethrow;
    } catch (e) {
      _log.e('getInstallmentWithPayments', error: e);
      throw ServerException(e.toString());
    }
  }

  @override
  Future<InstallmentModel> addInstallment(AddInstallmentParams params) async {
    try {
      final isOffice = params.clientType == ClientType.office;

      // Computed fields — discount is absorbed from profit, capital is unchanged
      final effectiveProfitAmount = params.profitAmount - params.discountPerMonth * params.durationMonths;
      final totalDebt = params.capital + effectiveProfitAmount;
      final monthlyAmount = totalDebt / params.durationMonths;
      final profitPerPayment = effectiveProfitAmount / params.durationMonths;
      final officeCommissionAmount =
          isOffice ? params.capital * AppConstants.kOfficeCommissionRate : 0.0;

      // First payment due: day 10 of next month after startDate
      final nextMonth =
          AppDateUtils.addMonths(params.startDate, 1);
      final firstPaymentDueDate = DateTime(
        nextMonth.year,
        nextMonth.month,
        AppConstants.kPaymentDueDay,
      );

      final now = DateTime.now();
      final officeCommissionPaid =
          isOffice && params.officeCommissionPaidAtCreation;

      final instRef = _installmentsRef.doc();
      final installment = InstallmentModel(
        id: instRef.id,
        clientId: params.clientId,
        itemName: params.itemName,
        capital: params.capital,
        profitAmount: effectiveProfitAmount,
        discountPerMonth: params.discountPerMonth,
        profitPerPayment: profitPerPayment,
        monthlyAmount: monthlyAmount,
        totalDebt: totalDebt,
        durationMonths: params.durationMonths,
        startDate: params.startDate,
        firstPaymentDueDate: firstPaymentDueDate,
        officeCommissionAmount: officeCommissionAmount,
        officeCommissionPaid: officeCommissionPaid,
        officeCommissionPaidAt: officeCommissionPaid ? now : null,
        paidPaymentsCount: 0,
        totalPaymentsCount: params.durationMonths,
        totalPaidAmount: 0,
        recognizedProfit: 0,
        status: InstallmentStatus.active,
        editLocked: false,
        createdAt: now,
        updatedAt: now,
      );

      // Generate payment schedule
      final paymentDocs = <(DocumentReference<Map<String, dynamic>>, Map<String, dynamic>)>[];
      for (int i = 1; i <= params.durationMonths; i++) {
        final dueMonthDate =
            AppDateUtils.addMonths(firstPaymentDueDate, i - 1);
        final dueDate = DateTime(
          dueMonthDate.year,
          dueMonthDate.month,
          AppConstants.kPaymentDueDay,
        );
        final dueMonth = AppDateUtils.yearMonthKey(dueDate);
        final status =
            StatusUtils.computeInstallmentPaymentStatus(dueDate, now);

        final payRef = _paymentsRef.doc();
        final payData = PaymentModel(
          id: payRef.id,
          clientId: params.clientId,
          installmentId: instRef.id,
          monthIndex: i,
          dueDate: dueDate,
          dueMonth: dueMonth,
          amount: monthlyAmount,
          profitPortion: profitPerPayment,
          status: status,
          paidDate: null,
          paidAt: null,
          createdAt: now,
          updatedAt: now,
        ).toFirestore();

        paymentDocs.add((payRef, payData));
      }

      final batch = _firestore.batch();

      // Create installment
      batch.set(instRef, installment.toFirestore());

      // Create payment docs
      for (final (ref, data) in paymentDocs) {
        batch.set(ref, data);
      }

      // Increment client totals
      batch.set(
        _clientRef(params.clientId),
        {
          'totalRemaining': FieldValue.increment(totalDebt),
          'activeDebtsCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // Increment allTime capital
      batch.set(
        _allTimeRef,
        {
          'totalCapital': FieldValue.increment(params.capital),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // If office commission paid at creation, also create transaction + increment commission
      if (officeCommissionPaid) {
        final txRef = _transactionsRef.doc();
        batch.set(txRef, {
          'clientId': params.clientId,
          'relatedId': instRef.id,
          'relatedType': 'office_commission',
          'installmentId': instRef.id,
          'gracePeriodId': null,
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
      return installment;
    } catch (e) {
      _log.e('addInstallment', error: e);
      throw ServerException(e.toString());
    }
  }

  // 8.5 — checked in repo impl before calling this
  @override
  Future<InstallmentModel> editInstallment(EditInstallmentParams params) async {
    try {
      final uid = _uid;

      // Computed new values — discount absorbed from profit
      final effectiveProfitAmount = params.profitAmount - params.discountPerMonth * params.durationMonths;
      final totalDebt = params.capital + effectiveProfitAmount;
      final monthlyAmount = totalDebt / params.durationMonths;
      final profitPerPayment = effectiveProfitAmount / params.durationMonths;

      final nextMonth = AppDateUtils.addMonths(params.startDate, 1);
      final firstPaymentDueDate = DateTime(
        nextMonth.year,
        nextMonth.month,
        AppConstants.kPaymentDueDay,
      );

      final now = DateTime.now();

      // Fetch old installment for totalDebt diff
      final oldDoc =
          await _installmentsRef.doc(params.id).get();
      if (!oldDoc.exists) throw ServerException('القسط غير موجود');
      final oldInstallment = InstallmentModel.fromFirestore(oldDoc);
      final oldTotalDebt = oldInstallment.totalDebt;

      // Fetch existing payment IDs to delete
      final oldPaymentsSnap = await _paymentsRef
          .where('installmentId', isEqualTo: params.id)
          .get();

      final batch = _firestore.batch();

      // Update installment
      batch.update(_installmentsRef.doc(params.id), {
        'itemName': params.itemName,
        'capital': params.capital,
        'profitAmount': effectiveProfitAmount,
        'discountPerMonth': params.discountPerMonth,
        'profitPerPayment': profitPerPayment,
        'monthlyAmount': monthlyAmount,
        'totalDebt': totalDebt,
        'durationMonths': params.durationMonths,
        'startDate': Timestamp.fromDate(params.startDate),
        'firstPaymentDueDate': Timestamp.fromDate(firstPaymentDueDate),
        'totalPaymentsCount': params.durationMonths,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Delete old payments
      for (final doc in oldPaymentsSnap.docs) {
        batch.delete(doc.reference);
      }

      // Create new payment schedule
      for (int i = 1; i <= params.durationMonths; i++) {
        final dueMonthDate =
            AppDateUtils.addMonths(firstPaymentDueDate, i - 1);
        final dueDate = DateTime(
          dueMonthDate.year,
          dueMonthDate.month,
          AppConstants.kPaymentDueDay,
        );
        final dueMonth = AppDateUtils.yearMonthKey(dueDate);
        final status =
            StatusUtils.computeInstallmentPaymentStatus(dueDate, now);

        final payRef = _paymentsRef.doc();
        batch.set(payRef, PaymentModel(
          id: payRef.id,
          clientId: params.clientId,
          installmentId: params.id,
          monthIndex: i,
          dueDate: dueDate,
          dueMonth: dueMonth,
          amount: monthlyAmount,
          profitPortion: profitPerPayment,
          status: status,
          paidDate: null,
          paidAt: null,
          createdAt: now,
          updatedAt: now,
        ).toFirestore());
      }

      // Adjust client totalRemaining for the diff
      final diff = totalDebt - oldTotalDebt;
      if (diff != 0) {
        batch.set(
          _firestore.doc(FirestorePaths.client(uid, params.clientId)),
          {
            'totalRemaining': FieldValue.increment(diff),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      await batch.commit();

      final updatedDoc = await _installmentsRef.doc(params.id).get();
      return InstallmentModel.fromFirestore(updatedDoc);
    } catch (e) {
      _log.e('editInstallment', error: e);
      throw ServerException(e.toString());
    }
  }

  // 8.6 — pay office commission
  @override
  Future<void> payOfficeCommission(String installmentId) async {
    try {
      final uid = _uid;
      final now = DateTime.now();

      final instDoc = await _installmentsRef.doc(installmentId).get();
      if (!instDoc.exists) throw ServerException('القسط غير موجود');
      final installment = InstallmentModel.fromFirestore(instDoc);

      if (installment.officeCommissionPaid) {
        throw ServerException('تم دفع العمولة مسبقاً');
      }

      final txRef = _transactionsRef.doc();

      await _firestore.runTransaction((tx) async {
        tx.update(_installmentsRef.doc(installmentId), {
          'officeCommissionPaid': true,
          'officeCommissionPaidAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        tx.set(txRef, {
          'clientId': installment.clientId,
          'relatedId': installmentId,
          'relatedType': 'office_commission',
          'installmentId': installmentId,
          'gracePeriodId': null,
          'amount': installment.officeCommissionAmount,
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
                FieldValue.increment(installment.officeCommissionAmount),
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

  @override
  Future<void> deleteInstallment(String installmentId) async {
    try {
      final instDoc = await _installmentsRef.doc(installmentId).get();
      if (!instDoc.exists) throw ServerException('القسط غير موجود');
      final installment = InstallmentModel.fromFirestore(instDoc);

      if (installment.paidPaymentsCount > 0) {
        throw ServerException('لا يمكن حذف قسط تم سداد دفعة منه');
      }

      final paymentsSnap = await _paymentsRef
          .where('installmentId', isEqualTo: installmentId)
          .get();

      final batch = _firestore.batch();

      for (final doc in paymentsSnap.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_installmentsRef.doc(installmentId));
      batch.set(
        _clientRef(installment.clientId),
        {
          'totalRemaining': FieldValue.increment(-installment.totalDebt),
          'activeDebtsCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      batch.set(
        _allTimeRef,
        {
          'totalCapital': FieldValue.increment(-installment.capital),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      await batch.commit();
    } catch (e) {
      _log.e('deleteInstallment', error: e);
      throw ServerException(e.toString());
    }
  }

}
