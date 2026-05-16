// lib/features/installments/data/models/installment_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/installment_entity.dart';

class InstallmentModel extends InstallmentEntity {
  const InstallmentModel({
    required super.id,
    required super.clientId,
    required super.itemName,
    required super.capital,
    required super.profitAmount,
    required super.discountPerMonth,
    required super.profitPerPayment,
    required super.monthlyAmount,
    required super.totalDebt,
    required super.durationMonths,
    required super.startDate,
    required super.firstPaymentDueDate,
    required super.officeCommissionAmount,
    required super.officeCommissionPaid,
    super.officeCommissionPaidAt,
    required super.paidPaymentsCount,
    required super.totalPaymentsCount,
    required super.totalPaidAmount,
    required super.recognizedProfit,
    required super.status,
    required super.editLocked,
    required super.createdAt,
    required super.updatedAt,
  });

  factory InstallmentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return InstallmentModel(
      id: doc.id,
      clientId: data['clientId'] as String? ?? '',
      itemName: data['itemName'] as String? ?? '',
      capital: (data['capital'] as num?)?.toDouble() ?? 0,
      profitAmount: (data['profitAmount'] as num?)?.toDouble() ?? 0,
      discountPerMonth: (data['discountPerMonth'] as num?)?.toDouble() ?? 0,
      profitPerPayment: (data['profitPerPayment'] as num?)?.toDouble() ?? 0,
      monthlyAmount: (data['monthlyAmount'] as num?)?.toDouble() ?? 0,
      totalDebt: (data['totalDebt'] as num?)?.toDouble() ?? 0,
      durationMonths: (data['durationMonths'] as num?)?.toInt() ?? 0,
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      firstPaymentDueDate:
          (data['firstPaymentDueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      officeCommissionAmount:
          (data['officeCommissionAmount'] as num?)?.toDouble() ?? 0,
      officeCommissionPaid: data['officeCommissionPaid'] as bool? ?? false,
      officeCommissionPaidAt:
          (data['officeCommissionPaidAt'] as Timestamp?)?.toDate(),
      paidPaymentsCount: (data['paidPaymentsCount'] as num?)?.toInt() ?? 0,
      totalPaymentsCount: (data['totalPaymentsCount'] as num?)?.toInt() ?? 0,
      totalPaidAmount: (data['totalPaidAmount'] as num?)?.toDouble() ?? 0,
      recognizedProfit: (data['recognizedProfit'] as num?)?.toDouble() ?? 0,
      status: _statusFromString(data['status'] as String?),
      editLocked: data['editLocked'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'clientId': clientId,
        'itemName': itemName,
        'capital': capital,
        'profitAmount': profitAmount,
        'discountPerMonth': discountPerMonth,
        'profitPerPayment': profitPerPayment,
        'monthlyAmount': monthlyAmount,
        'totalDebt': totalDebt,
        'durationMonths': durationMonths,
        'startDate': Timestamp.fromDate(startDate),
        'firstPaymentDueDate': Timestamp.fromDate(firstPaymentDueDate),
        'officeCommissionAmount': officeCommissionAmount,
        'officeCommissionPaid': officeCommissionPaid,
        'officeCommissionPaidAt': officeCommissionPaidAt != null
            ? Timestamp.fromDate(officeCommissionPaidAt!)
            : null,
        'paidPaymentsCount': paidPaymentsCount,
        'totalPaymentsCount': totalPaymentsCount,
        'totalPaidAmount': totalPaidAmount,
        'recognizedProfit': recognizedProfit,
        'status': status.name,
        'editLocked': editLocked,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  static InstallmentStatus _statusFromString(String? value) {
    if (value == 'completed') return InstallmentStatus.completed;
    return InstallmentStatus.active;
  }
}
