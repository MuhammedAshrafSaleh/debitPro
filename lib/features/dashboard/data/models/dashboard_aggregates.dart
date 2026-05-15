// lib/features/dashboard/data/models/dashboard_aggregates.dart

class DashboardAggregates {
  const DashboardAggregates({
    required this.monthlyCollection,
    required this.monthlyTarget,
    required this.totalProfits,
    required this.totalCapital,
    required this.totalOfficeCommission,
    required this.totalClients,
  });

  final double monthlyCollection;
  final double monthlyTarget;
  final double totalProfits;
  final double totalCapital;
  final double totalOfficeCommission;
  final int totalClients;
}
