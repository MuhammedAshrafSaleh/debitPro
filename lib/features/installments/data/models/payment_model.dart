// lib/features/installments/data/models/payment_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/status_utils.dart';
import '../../domain/entities/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.clientId,
    required super.installmentId,
    required super.monthIndex,
    required super.dueDate,
    required super.dueMonth,
    required super.amount,
    required super.profitPortion,
    required super.status,
    super.paidDate,
    super.paidAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PaymentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return PaymentModel(
      id: doc.id,
      clientId: data['clientId'] as String? ?? '',
      installmentId: data['installmentId'] as String? ?? '',
      monthIndex: (data['monthIndex'] as num?)?.toInt() ?? 0,
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dueMonth: data['dueMonth'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      profitPortion: (data['profitPortion'] as num?)?.toDouble() ?? 0,
      status: _statusFromString(data['status'] as String?),
      paidDate: (data['paidDate'] as Timestamp?)?.toDate(),
      paidAt: (data['paidAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'clientId': clientId,
        'installmentId': installmentId,
        'monthIndex': monthIndex,
        'dueDate': Timestamp.fromDate(dueDate),
        'dueMonth': dueMonth,
        'amount': amount,
        'profitPortion': profitPortion,
        'status': status.name,
        'paidDate': paidDate != null ? Timestamp.fromDate(paidDate!) : null,
        'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  static PaymentStatus _statusFromString(String? value) {
    switch (value) {
      case 'current':
        return PaymentStatus.current;
      case 'overdue':
        return PaymentStatus.overdue;
      case 'paid':
        return PaymentStatus.paid;
      case 'reversed':
        return PaymentStatus.reversed;
      default:
        return PaymentStatus.upcoming;
    }
  }
}
