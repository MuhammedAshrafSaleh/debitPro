// lib/features/payments/data/models/transaction_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.clientId,
    required super.relatedId,
    required super.relatedType,
    super.installmentId,
    super.gracePeriodId,
    required super.amount,
    super.profitPortion,
    required super.type,
    required super.status,
    required super.yearMonth,
    required super.paidDate,
    super.reversedAt,
    super.reversalNote,
    required super.createdAt,
  });

  factory TransactionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return TransactionModel(
      id: doc.id,
      clientId: data['clientId'] as String? ?? '',
      relatedId: data['relatedId'] as String? ?? '',
      relatedType: RelatedTypeX.fromWire(data['relatedType'] as String?),
      installmentId: data['installmentId'] as String?,
      gracePeriodId: data['gracePeriodId'] as String?,
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      profitPortion: (data['profitPortion'] as num?)?.toDouble(),
      type: TransactionTypeX.fromWire(data['type'] as String?),
      status: TransactionStatusX.fromWire(data['status'] as String?),
      yearMonth: data['yearMonth'] as String? ?? '',
      paidDate:
          (data['paidDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reversedAt: (data['reversedAt'] as Timestamp?)?.toDate(),
      reversalNote: data['reversalNote'] as String?,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'clientId': clientId,
        'relatedId': relatedId,
        'relatedType': relatedType.wireValue,
        'installmentId': installmentId,
        'gracePeriodId': gracePeriodId,
        'amount': amount,
        'profitPortion': profitPortion,
        'type': type.wireValue,
        'status': status.wireValue,
        'yearMonth': yearMonth,
        'paidDate': Timestamp.fromDate(paidDate),
        'reversedAt':
            reversedAt != null ? Timestamp.fromDate(reversedAt!) : null,
        'reversalNote': reversalNote,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
