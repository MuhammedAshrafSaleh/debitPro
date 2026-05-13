// lib/features/installments/domain/repositories/installment_repository.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../features/clients/domain/entities/client_entity.dart';
import '../entities/installment_entity.dart';
import '../entities/payment_entity.dart';

class InstallmentWithPayments {
  const InstallmentWithPayments({
    required this.installment,
    required this.payments,
  });

  final InstallmentEntity installment;
  final List<PaymentEntity> payments;
}

abstract class InstallmentRepository {
  Stream<List<InstallmentEntity>> watchInstallmentsForClient(String clientId);

  Future<Either<Failure, InstallmentWithPayments>> getInstallmentWithPayments(
    String installmentId,
  );

  Future<Either<Failure, InstallmentEntity>> addInstallment(
    AddInstallmentParams params,
  );

  Future<Either<Failure, InstallmentEntity>> editInstallment(
    EditInstallmentParams params,
  );

  Future<Either<Failure, void>> payOfficeCommission(String installmentId);
}

class AddInstallmentParams {
  const AddInstallmentParams({
    required this.clientId,
    required this.clientType,
    required this.officeCommissionPaidAtCreation,
    required this.itemName,
    required this.capital,
    required this.profitAmount,
    required this.durationMonths,
    required this.startDate,
  });

  final String clientId;
  final ClientType clientType;
  final bool officeCommissionPaidAtCreation;
  final String itemName;
  final double capital;
  final double profitAmount;
  final int durationMonths;
  final DateTime startDate;
}

class EditInstallmentParams {
  const EditInstallmentParams({
    required this.id,
    required this.clientId,
    required this.itemName,
    required this.capital,
    required this.profitAmount,
    required this.durationMonths,
    required this.startDate,
  });

  final String id;
  final String clientId;
  final String itemName;
  final double capital;
  final double profitAmount;
  final int durationMonths;
  final DateTime startDate;
}
