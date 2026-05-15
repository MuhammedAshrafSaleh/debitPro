// lib/features/dashboard/domain/entities/dashboard_data.dart

import 'package:equatable/equatable.dart';

import '../../../payments/domain/entities/transaction_entity.dart';

class DashboardData extends Equatable {
  const DashboardData({
    required this.monthlyCollection,
    required this.monthlyTarget,
    required this.totalProfits,
    required this.totalCapital,
    required this.totalOfficeCommission,
    required this.totalClients,
    required this.recentTransactions,
    required this.clientNamesById,
  });

  final double monthlyCollection;
  final double monthlyTarget;
  final double totalProfits;
  final double totalCapital;
  final double totalOfficeCommission;
  final int totalClients;
  final List<TransactionEntity> recentTransactions;
  final Map<String, String> clientNamesById;

  /// Ratio of [monthlyCollection] / [monthlyTarget], clamped to `[0, 1]`.
  /// Returns `0` when target is zero to avoid NaN.
  double get collectionProgress {
    if (monthlyTarget <= 0) return 0;
    final ratio = monthlyCollection / monthlyTarget;
    if (ratio.isNaN || ratio.isInfinite) return 0;
    return ratio.clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [
        monthlyCollection,
        monthlyTarget,
        totalProfits,
        totalCapital,
        totalOfficeCommission,
        totalClients,
        recentTransactions,
        clientNamesById,
      ];
}
