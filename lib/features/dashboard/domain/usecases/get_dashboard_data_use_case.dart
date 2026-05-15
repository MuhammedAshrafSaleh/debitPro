// lib/features/dashboard/domain/usecases/get_dashboard_data_use_case.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/dashboard_data.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardDataUseCase {
  GetDashboardDataUseCase(this._repository);

  final DashboardRepository _repository;

  Future<Either<Failure, DashboardData>> call({required DateTime now}) {
    return _repository.getDashboardData(now);
  }
}
