// lib/features/grace_periods/domain/entities/grace_period_entity.dart

import 'package:equatable/equatable.dart';

import '../../../../core/utils/status_utils.dart';

class GracePeriodEntity extends Equatable {
  const GracePeriodEntity({
    required this.id,
    required this.clientId,
    required this.name,
    required this.capital,
    this.notes,
    required this.dueDate,
    required this.gracePeriodEndDate,
    required this.officeCommissionAmount,
    required this.officeCommissionPaid,
    this.officeCommissionPaidAt,
    required this.status,
    this.paidDate,
    this.paidAt,
    required this.editLocked,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String clientId;
  final String name;
  final double capital;
  final String? notes;
  final DateTime dueDate;
  final DateTime gracePeriodEndDate;
  final double officeCommissionAmount;
  final bool officeCommissionPaid;
  final DateTime? officeCommissionPaidAt;
  final GracePeriodStatus status;
  final DateTime? paidDate;
  final DateTime? paidAt;
  final bool editLocked;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id, clientId, name, capital, notes,
        dueDate, gracePeriodEndDate,
        officeCommissionAmount, officeCommissionPaid, officeCommissionPaidAt,
        status, paidDate, paidAt, editLocked, createdAt, updatedAt,
      ];
}
