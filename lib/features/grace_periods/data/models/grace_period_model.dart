// lib/features/grace_periods/data/models/grace_period_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/status_utils.dart';
import '../../domain/entities/grace_period_entity.dart';

class GracePeriodModel extends GracePeriodEntity {
  const GracePeriodModel({
    required super.id,
    required super.clientId,
    required super.name,
    required super.capital,
    super.notes,
    required super.dueDate,
    required super.gracePeriodEndDate,
    required super.officeCommissionAmount,
    required super.officeCommissionPaid,
    super.officeCommissionPaidAt,
    required super.status,
    super.paidDate,
    super.paidAt,
    required super.editLocked,
    required super.createdAt,
    required super.updatedAt,
  });

  factory GracePeriodModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return GracePeriodModel(
      id: doc.id,
      clientId: data['clientId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      capital: (data['capital'] as num?)?.toDouble() ?? 0,
      notes: data['notes'] as String?,
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      gracePeriodEndDate:
          (data['gracePeriodEndDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      officeCommissionAmount:
          (data['officeCommissionAmount'] as num?)?.toDouble() ?? 0,
      officeCommissionPaid: data['officeCommissionPaid'] as bool? ?? false,
      officeCommissionPaidAt:
          (data['officeCommissionPaidAt'] as Timestamp?)?.toDate(),
      status: _statusFromString(data['status'] as String?),
      paidDate: (data['paidDate'] as Timestamp?)?.toDate(),
      paidAt: (data['paidAt'] as Timestamp?)?.toDate(),
      editLocked: data['editLocked'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'clientId': clientId,
        'name': name,
        'capital': capital,
        'notes': notes,
        'dueDate': Timestamp.fromDate(dueDate),
        'gracePeriodEndDate': Timestamp.fromDate(gracePeriodEndDate),
        'officeCommissionAmount': officeCommissionAmount,
        'officeCommissionPaid': officeCommissionPaid,
        'officeCommissionPaidAt': officeCommissionPaidAt != null
            ? Timestamp.fromDate(officeCommissionPaidAt!)
            : null,
        'status': _statusToString(status),
        'paidDate': paidDate != null ? Timestamp.fromDate(paidDate!) : null,
        'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
        'editLocked': editLocked,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  static GracePeriodStatus _statusFromString(String? value) {
    switch (value) {
      case 'grace_window':
        return GracePeriodStatus.graceWindow;
      case 'overdue':
        return GracePeriodStatus.overdue;
      case 'paid':
        return GracePeriodStatus.paid;
      default:
        return GracePeriodStatus.upcoming;
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
