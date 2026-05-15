// lib/features/payments/data/datasources/firestore_payment_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/status_utils.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../models/transaction_model.dart';

abstract class PaymentRemoteDataSource {
  Future<void> payInstallmentPayment(PayInstallmentPaymentParams params);
  Future<void> payGracePeriod(PayGracePeriodParams params);
  Future<void> reversePayment(ReversePaymentParams params);
  Stream<List<TransactionModel>> watchTransactionsForClient(String clientId);
  Future<List<TransactionModel>> getTransactions(TransactionsFilter filter);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  PaymentRemoteDataSourceImpl(this._firestore, this._auth);

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

  CollectionReference<Map<String, dynamic>> get _transactionsRef =>
      _firestore.collection(FirestorePaths.transactions(_uid));

  DocumentReference<Map<String, dynamic>> _clientRef(String clientId) =>
      _firestore.doc(FirestorePaths.client(_uid, clientId));

  DocumentReference<Map<String, dynamic>> get _allTimeRef =>
      _firestore.doc(FirestorePaths.allTimeAgg(_uid));

  DocumentReference<Map<String, dynamic>> _monthlyRef(String yearMonth) =>
      _firestore.doc(FirestorePaths.monthlyAgg(_uid, yearMonth));

  // ──────────────────────────────────────────────────────────────────────────
  // Pay installment payment — full atomic transaction (schema §Atomic Ops)
  // ──────────────────────────────────────────────────────────────────────────
  @override
  Future<void> payInstallmentPayment(PayInstallmentPaymentParams params) async {
    final payment = params.payment;
    final now = params.now;
    final today = DateTime(now.year, now.month, now.day);

    try {
      final payRef = _paymentsRef.doc(payment.id);
      final instRef = _installmentsRef.doc(payment.installmentId);
      final clientRef = _clientRef(payment.clientId);
      final monthlyRef = _monthlyRef(payment.dueMonth);
      final txLogRef = _transactionsRef.doc();

      await _firestore.runTransaction((tx) async {
        // Reads first
        final payDoc = await tx.get(payRef);
        if (!payDoc.exists) {
          throw ServerException('الدفعة غير موجودة');
        }
        final payData = payDoc.data()!;
        if (payData['status'] == 'paid') {
          throw AlreadyPaidException('تم دفع هذه الدفعة مسبقاً');
        }

        final instDoc = await tx.get(instRef);
        if (!instDoc.exists) {
          throw ServerException('القسط غير موجود');
        }
        final instData = instDoc.data()!;

        final clientDoc = await tx.get(clientRef);
        if (!clientDoc.exists) {
          throw ServerException('العميل غير موجود');
        }
        final clientData = clientDoc.data()!;

        final paidCount =
            ((instData['paidPaymentsCount'] as num?) ?? 0).toInt();
        final totalCount =
            ((instData['totalPaymentsCount'] as num?) ?? 0).toInt();
        final newPaidCount = paidCount + 1;
        final isCompleted = newPaidCount >= totalCount;
        final isOnTime = today.day <= AppConstants.kPaymentDueDay;

        final onTime = ((clientData['onTimePaymentsCount'] as num?) ?? 0).toInt() +
            (isOnTime ? 1 : 0);
        final totalDue =
            ((clientData['totalDuePaymentsCount'] as num?) ?? 0).toInt() + 1;
        final qualityScore = StatusUtils.qualityScore(onTime, totalDue);

        // Writes
        tx.update(payRef, {
          'status': 'paid',
          'paidDate': Timestamp.fromDate(today),
          'paidAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        tx.update(instRef, {
          'paidPaymentsCount': FieldValue.increment(1),
          'totalPaidAmount': FieldValue.increment(payment.amount),
          'recognizedProfit': FieldValue.increment(payment.profitPortion),
          'editLocked': true,
          'status': isCompleted ? 'completed' : 'active',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        tx.set(
          clientRef,
          {
            'totalPaid': FieldValue.increment(payment.amount),
            'totalRemaining': FieldValue.increment(-payment.amount),
            'totalDuePaymentsCount': FieldValue.increment(1),
            if (isOnTime) 'onTimePaymentsCount': FieldValue.increment(1),
            'paymentQualityScore': qualityScore,
            if (isCompleted) 'activeDebtsCount': FieldValue.increment(-1),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        tx.set(txLogRef, {
          'clientId': payment.clientId,
          'relatedId': payment.id,
          'relatedType': RelatedType.installmentPayment.wireValue,
          'installmentId': payment.installmentId,
          'gracePeriodId': null,
          'amount': payment.amount,
          'profitPortion': payment.profitPortion,
          'type': TransactionType.payment.wireValue,
          'status': TransactionStatus.completed.wireValue,
          'yearMonth': payment.dueMonth,
          'paidDate': Timestamp.fromDate(today),
          'reversedAt': null,
          'reversalNote': null,
          'createdAt': FieldValue.serverTimestamp(),
        });

        tx.set(
          monthlyRef,
          {
            'yearMonth': payment.dueMonth,
            'monthlyCollection': FieldValue.increment(payment.amount),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        tx.set(
          _allTimeRef,
          {
            'totalRecognizedProfit':
                FieldValue.increment(payment.profitPortion),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      });
    } on ServerException {
      rethrow;
    } on AlreadyPaidException {
      rethrow;
    } catch (e) {
      _log.e('payInstallmentPayment', error: e);
      throw ServerException(e.toString());
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Pay grace period — full atomic transaction
  // ──────────────────────────────────────────────────────────────────────────
  @override
  Future<void> payGracePeriod(PayGracePeriodParams params) async {
    final gp = params.gracePeriod;
    final now = params.now;
    final today = DateTime(now.year, now.month, now.day);
    final yearMonth = AppDateUtils.yearMonthKey(today);

    try {
      final gpRef = _gracePeriodsRef.doc(gp.id);
      final clientRef = _clientRef(gp.clientId);
      final monthlyRef = _monthlyRef(yearMonth);
      final txLogRef = _transactionsRef.doc();

      await _firestore.runTransaction((tx) async {
        final gpDoc = await tx.get(gpRef);
        if (!gpDoc.exists) {
          throw ServerException('المهلة غير موجودة');
        }
        final gpData = gpDoc.data()!;
        if (gpData['status'] == 'paid') {
          throw AlreadyPaidException('تم سداد هذه المهلة مسبقاً');
        }

        final clientDoc = await tx.get(clientRef);
        if (!clientDoc.exists) {
          throw ServerException('العميل غير موجود');
        }
        final clientData = clientDoc.data()!;

        final isOnTime = !today.isAfter(gp.gracePeriodEndDate);
        final onTime = ((clientData['onTimePaymentsCount'] as num?) ?? 0).toInt() +
            (isOnTime ? 1 : 0);
        final totalDue =
            ((clientData['totalDuePaymentsCount'] as num?) ?? 0).toInt() + 1;
        final qualityScore = StatusUtils.qualityScore(onTime, totalDue);

        tx.update(gpRef, {
          'status': 'paid',
          'editLocked': true,
          'paidDate': Timestamp.fromDate(today),
          'paidAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        tx.set(
          clientRef,
          {
            'totalPaid': FieldValue.increment(gp.capital),
            'totalRemaining': FieldValue.increment(-gp.capital),
            'totalDuePaymentsCount': FieldValue.increment(1),
            if (isOnTime) 'onTimePaymentsCount': FieldValue.increment(1),
            'paymentQualityScore': qualityScore,
            'activeDebtsCount': FieldValue.increment(-1),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        tx.set(txLogRef, {
          'clientId': gp.clientId,
          'relatedId': gp.id,
          'relatedType': RelatedType.gracePeriod.wireValue,
          'installmentId': null,
          'gracePeriodId': gp.id,
          'amount': gp.capital,
          'profitPortion': null,
          'type': TransactionType.payment.wireValue,
          'status': TransactionStatus.completed.wireValue,
          'yearMonth': yearMonth,
          'paidDate': Timestamp.fromDate(today),
          'reversedAt': null,
          'reversalNote': null,
          'createdAt': FieldValue.serverTimestamp(),
        });

        tx.set(
          monthlyRef,
          {
            'yearMonth': yearMonth,
            'monthlyCollection': FieldValue.increment(gp.capital),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      });
    } on ServerException {
      rethrow;
    } on AlreadyPaidException {
      rethrow;
    } catch (e) {
      _log.e('payGracePeriod', error: e);
      throw ServerException(e.toString());
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Reverse payment — applies to installment payments and grace periods
  // ──────────────────────────────────────────────────────────────────────────
  @override
  Future<void> reversePayment(ReversePaymentParams params) async {
    final now = params.now;
    final today = DateTime(now.year, now.month, now.day);
    final currentYearMonth = AppDateUtils.yearMonthKey(today);

    try {
      final txRef = await _resolveTransactionRef(params);

      if (params.relatedType == RelatedType.installmentPayment) {
        await _reverseInstallmentPayment(
          txRef: txRef,
          paymentId: params.relatedId,
          now: now,
          today: today,
          currentYearMonth: currentYearMonth,
          reversalNote: params.reversalNote,
        );
      } else if (params.relatedType == RelatedType.gracePeriod) {
        await _reverseGracePeriod(
          txRef: txRef,
          gracePeriodId: params.relatedId,
          now: now,
          today: today,
          currentYearMonth: currentYearMonth,
          reversalNote: params.reversalNote,
        );
      } else {
        throw ServerException('لا يمكن إلغاء عمولة المكتب');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      _log.e('reversePayment', error: e);
      throw ServerException(e.toString());
    }
  }

  Future<DocumentReference<Map<String, dynamic>>> _resolveTransactionRef(
    ReversePaymentParams params,
  ) async {
    if (params.transactionId != null) {
      return _transactionsRef.doc(params.transactionId);
    }
    // Uses the (relatedId ASC, createdAt DESC) composite index. The `completed`
    // filter is applied client-side so we don't need a 3-field index.
    final snap = await _transactionsRef
        .where('relatedId', isEqualTo: params.relatedId)
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();
    for (final doc in snap.docs) {
      if (doc.data()['status'] == 'completed') {
        return doc.reference;
      }
    }
    throw ServerException('لم يتم العثور على العملية الأصلية');
  }

  Future<void> _reverseInstallmentPayment({
    required DocumentReference<Map<String, dynamic>> txRef,
    required String paymentId,
    required DateTime now,
    required DateTime today,
    required String currentYearMonth,
    String? reversalNote,
  }) async {
    final payRef = _paymentsRef.doc(paymentId);

    await _firestore.runTransaction((tx) async {
      final txDoc = await tx.get(txRef);
      if (!txDoc.exists) {
        throw ServerException('العملية غير موجودة');
      }
      final txData = txDoc.data()!;
      if (txData['status'] == 'reversed') {
        throw ServerException('تم إلغاء هذه العملية مسبقاً');
      }

      final payDoc = await tx.get(payRef);
      if (!payDoc.exists) {
        throw ServerException('الدفعة غير موجودة');
      }
      final payData = payDoc.data()!;
      if (payData['status'] != 'paid') {
        throw ServerException('هذه الدفعة غير مدفوعة');
      }

      final installmentId = payData['installmentId'] as String;
      final clientId = payData['clientId'] as String;
      final amount = (payData['amount'] as num).toDouble();
      final profitPortion = (payData['profitPortion'] as num).toDouble();
      final dueMonth = payData['dueMonth'] as String;

      final instRef = _installmentsRef.doc(installmentId);
      final instDoc = await tx.get(instRef);
      if (!instDoc.exists) {
        throw ServerException('القسط غير موجود');
      }
      final instData = instDoc.data()!;
      final newPaidCount =
          ((instData['paidPaymentsCount'] as num?) ?? 0).toInt() - 1;
      final wasCompleted = instData['status'] == 'completed';

      final clientRef = _clientRef(clientId);
      final clientDoc = await tx.get(clientRef);
      if (!clientDoc.exists) {
        throw ServerException('العميل غير موجود');
      }
      final clientData = clientDoc.data()!;

      // Recover whether the original payment was on-time using the
      // transaction's paidDate snapshot (not the payment doc).
      final originalPaid =
          (txData['paidDate'] as Timestamp?)?.toDate() ?? today;
      final wasOnTime =
          originalPaid.day <= AppConstants.kPaymentDueDay;

      final onTime =
          ((clientData['onTimePaymentsCount'] as num?) ?? 0).toInt() -
              (wasOnTime ? 1 : 0);
      final totalDue =
          ((clientData['totalDuePaymentsCount'] as num?) ?? 0).toInt() - 1;
      final qualityScore = StatusUtils.qualityScore(
        onTime < 0 ? 0 : onTime,
        totalDue < 0 ? 0 : totalDue,
      );

      // Recompute payment status from the schedule
      final dueDate =
          (payData['dueDate'] as Timestamp).toDate();
      final newStatus = StatusUtils.computeInstallmentPaymentStatus(
        dueDate,
        today,
      );

      // Writes
      tx.update(payRef, {
        'status': newStatus.name,
        'paidDate': null,
        'paidAt': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      tx.update(instRef, {
        'paidPaymentsCount': FieldValue.increment(-1),
        'totalPaidAmount': FieldValue.increment(-amount),
        'recognizedProfit': FieldValue.increment(-profitPortion),
        if (newPaidCount == 0) 'editLocked': false,
        if (wasCompleted) 'status': 'active',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      tx.set(
        clientRef,
        {
          'totalPaid': FieldValue.increment(-amount),
          'totalRemaining': FieldValue.increment(amount),
          'totalDuePaymentsCount': FieldValue.increment(-1),
          if (wasOnTime) 'onTimePaymentsCount': FieldValue.increment(-1),
          'paymentQualityScore': qualityScore,
          if (wasCompleted) 'activeDebtsCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      tx.update(txRef, {
        'status': TransactionStatus.reversed.wireValue,
        'reversedAt': FieldValue.serverTimestamp(),
        'reversalNote': reversalNote,
      });

      // Adjust monthly aggregate only if reversing within the original month
      if (dueMonth == currentYearMonth) {
        tx.set(
          _monthlyRef(dueMonth),
          {
            'yearMonth': dueMonth,
            'monthlyCollection': FieldValue.increment(-amount),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      tx.set(
        _allTimeRef,
        {
          'totalRecognizedProfit': FieldValue.increment(-profitPortion),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }

  Future<void> _reverseGracePeriod({
    required DocumentReference<Map<String, dynamic>> txRef,
    required String gracePeriodId,
    required DateTime now,
    required DateTime today,
    required String currentYearMonth,
    String? reversalNote,
  }) async {
    final gpRef = _gracePeriodsRef.doc(gracePeriodId);

    await _firestore.runTransaction((tx) async {
      final txDoc = await tx.get(txRef);
      if (!txDoc.exists) {
        throw ServerException('العملية غير موجودة');
      }
      final txData = txDoc.data()!;
      if (txData['status'] == 'reversed') {
        throw ServerException('تم إلغاء هذه العملية مسبقاً');
      }

      final gpDoc = await tx.get(gpRef);
      if (!gpDoc.exists) {
        throw ServerException('المهلة غير موجودة');
      }
      final gpData = gpDoc.data()!;
      if (gpData['status'] != 'paid') {
        throw ServerException('هذه المهلة غير مدفوعة');
      }

      final clientId = gpData['clientId'] as String;
      final amount = (gpData['capital'] as num).toDouble();
      final dueDate = (gpData['dueDate'] as Timestamp).toDate();
      final gracePeriodEndDate =
          (gpData['gracePeriodEndDate'] as Timestamp).toDate();
      final originalPaid =
          (txData['paidDate'] as Timestamp?)?.toDate() ?? today;
      final txYearMonth = txData['yearMonth'] as String? ?? currentYearMonth;

      final clientRef = _clientRef(clientId);
      final clientDoc = await tx.get(clientRef);
      if (!clientDoc.exists) {
        throw ServerException('العميل غير موجود');
      }
      final clientData = clientDoc.data()!;

      final wasOnTime = !originalPaid.isAfter(gracePeriodEndDate);
      final onTime =
          ((clientData['onTimePaymentsCount'] as num?) ?? 0).toInt() -
              (wasOnTime ? 1 : 0);
      final totalDue =
          ((clientData['totalDuePaymentsCount'] as num?) ?? 0).toInt() - 1;
      final qualityScore = StatusUtils.qualityScore(
        onTime < 0 ? 0 : onTime,
        totalDue < 0 ? 0 : totalDue,
      );

      // Recompute grace period status from dueDate
      final newStatus =
          StatusUtils.computeGracePeriodStatus(dueDate, today);
      final newStatusWire = switch (newStatus) {
        GracePeriodStatus.upcoming => 'upcoming',
        GracePeriodStatus.graceWindow => 'grace_window',
        GracePeriodStatus.overdue => 'overdue',
        GracePeriodStatus.paid => 'paid',
      };

      tx.update(gpRef, {
        'status': newStatusWire,
        'paidDate': null,
        'paidAt': null,
        'editLocked': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      tx.set(
        clientRef,
        {
          'totalPaid': FieldValue.increment(-amount),
          'totalRemaining': FieldValue.increment(amount),
          'totalDuePaymentsCount': FieldValue.increment(-1),
          if (wasOnTime) 'onTimePaymentsCount': FieldValue.increment(-1),
          'paymentQualityScore': qualityScore,
          'activeDebtsCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      tx.update(txRef, {
        'status': TransactionStatus.reversed.wireValue,
        'reversedAt': FieldValue.serverTimestamp(),
        'reversalNote': reversalNote,
      });

      if (txYearMonth == currentYearMonth) {
        tx.set(
          _monthlyRef(txYearMonth),
          {
            'yearMonth': txYearMonth,
            'monthlyCollection': FieldValue.increment(-amount),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }
    });
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Queries
  // ──────────────────────────────────────────────────────────────────────────
  @override
  Stream<List<TransactionModel>> watchTransactionsForClient(String clientId) {
    return _transactionsRef
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .limit(200)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => TransactionModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<List<TransactionModel>> getTransactions(
    TransactionsFilter filter,
  ) async {
    try {
      Query<Map<String, dynamic>> q = _transactionsRef;

      if (filter.clientId != null) {
        q = q.where('clientId', isEqualTo: filter.clientId);
      }
      if (filter.fromYearMonth != null) {
        q = q.where('yearMonth', isGreaterThanOrEqualTo: filter.fromYearMonth);
      }
      if (filter.toYearMonth != null) {
        q = q.where('yearMonth', isLessThanOrEqualTo: filter.toYearMonth);
      }
      if (!filter.includeReversed) {
        q = q.where('status', isEqualTo: 'completed');
      }

      // Order by the filtered field if applicable, else by createdAt
      if (filter.fromYearMonth != null || filter.toYearMonth != null) {
        q = q.orderBy('yearMonth', descending: true);
      } else {
        q = q.orderBy('createdAt', descending: true);
      }

      q = q.limit(filter.limit);

      final snap = await q.get();
      return snap.docs.map(TransactionModel.fromFirestore).toList();
    } catch (e) {
      _log.e('getTransactions', error: e);
      throw ServerException(e.toString());
    }
  }
}
