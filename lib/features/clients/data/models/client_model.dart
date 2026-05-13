// lib/features/clients/data/models/client_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/client_entity.dart';

class ClientModel extends ClientEntity {
  const ClientModel({
    required super.id,
    required super.fullName,
    required super.phone,
    required super.gender,
    required super.documentationType,
    required super.clientType,
    super.notes,
    required super.totalPaid,
    required super.totalRemaining,
    required super.activeDebtsCount,
    required super.paymentQualityScore,
    required super.onTimePaymentsCount,
    required super.totalDuePaymentsCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ClientModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ClientModel(
      id: doc.id,
      fullName: data['fullName'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      gender: _genderFromString(data['gender'] as String?),
      documentationType: _docTypeFromString(data['documentationType'] as String?),
      clientType: _clientTypeFromString(data['clientType'] as String?),
      notes: data['notes'] as String?,
      totalPaid: (data['totalPaid'] as num?)?.toDouble() ?? 0,
      totalRemaining: (data['totalRemaining'] as num?)?.toDouble() ?? 0,
      activeDebtsCount: (data['activeDebtsCount'] as num?)?.toInt() ?? 0,
      paymentQualityScore: (data['paymentQualityScore'] as num?)?.toDouble() ?? 0,
      onTimePaymentsCount: (data['onTimePaymentsCount'] as num?)?.toInt() ?? 0,
      totalDuePaymentsCount: (data['totalDuePaymentsCount'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'fullName': fullName,
        'phone': phone,
        'gender': gender.name,
        'documentationType': documentationType.name,
        'clientType': clientType.name,
        'notes': notes,
        'totalPaid': totalPaid,
        'totalRemaining': totalRemaining,
        'activeDebtsCount': activeDebtsCount,
        'paymentQualityScore': paymentQualityScore,
        'onTimePaymentsCount': onTimePaymentsCount,
        'totalDuePaymentsCount': totalDuePaymentsCount,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  Map<String, dynamic> toFirestoreUpdate() => {
        'fullName': fullName,
        'phone': phone,
        'gender': gender.name,
        'documentationType': documentationType.name,
        'clientType': clientType.name,
        'notes': notes,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  static Gender _genderFromString(String? value) {
    if (value == 'female') return Gender.female;
    return Gender.male;
  }

  static DocumentationType _docTypeFromString(String? value) {
    if (value == 'paper') return DocumentationType.paper;
    return DocumentationType.electronic;
  }

  static ClientType _clientTypeFromString(String? value) {
    if (value == 'office') return ClientType.office;
    return ClientType.private;
  }
}
