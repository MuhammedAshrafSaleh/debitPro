// lib/features/clients/domain/entities/client_entity.dart

import 'package:equatable/equatable.dart';

enum Gender { male, female }

enum DocumentationType { electronic, paper }

enum ClientType { office, private }

enum ClientFilter { all, electronic, paper, office, private }

class ClientEntity extends Equatable {
  const ClientEntity({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.gender,
    required this.documentationType,
    required this.clientType,
    this.notes,
    required this.totalPaid,
    required this.totalRemaining,
    required this.activeDebtsCount,
    required this.paymentQualityScore,
    required this.onTimePaymentsCount,
    required this.totalDuePaymentsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String fullName;
  final String phone;
  final Gender gender;
  final DocumentationType documentationType;
  final ClientType clientType;
  final String? notes;

  // Computed totals
  final double totalPaid;
  final double totalRemaining;
  final int activeDebtsCount;

  // Payment quality
  final double paymentQualityScore;
  final int onTimePaymentsCount;
  final int totalDuePaymentsCount;

  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        fullName,
        phone,
        gender,
        documentationType,
        clientType,
        notes,
        totalPaid,
        totalRemaining,
        activeDebtsCount,
        paymentQualityScore,
        onTimePaymentsCount,
        totalDuePaymentsCount,
        createdAt,
        updatedAt,
      ];
}
