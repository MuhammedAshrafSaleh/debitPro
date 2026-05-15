// lib/features/payments/domain/usecases/refresh_payment_statuses_use_case.dart

import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../data/datasources/status_refresh_datasource.dart';

class RefreshPaymentStatusesUseCase {
  RefreshPaymentStatusesUseCase(this._dataSource, this._networkInfo);

  final StatusRefreshDataSource _dataSource;
  final NetworkInfo _networkInfo;
  final _log = Logger();

  Future<Either<Failure, StatusRefreshResult>> call({DateTime? now}) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      final result = await _dataSource.refresh(now ?? DateTime.now());
      return Right(result);
    } on ServerException catch (e) {
      _log.e('refreshPaymentStatuses', error: e);
      return Left(ServerFailure(e.message));
    } catch (e) {
      _log.e('refreshPaymentStatuses', error: e);
      return Left(ServerFailure(e.toString()));
    }
  }
}
