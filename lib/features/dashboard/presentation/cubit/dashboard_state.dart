// lib/features/dashboard/presentation/cubit/dashboard_state.dart

import 'package:equatable/equatable.dart';

import '../../domain/entities/dashboard_data.dart';

enum DashboardStatus { initial, loading, loaded, failure }

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.data,
    this.failureMessage,
  });

  final DashboardStatus status;
  final DashboardData? data;
  final String? failureMessage;

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardData? data,
    String? failureMessage,
    bool clearFailure = false,
  }) {
    return DashboardState(
      status: status ?? this.status,
      data: data ?? this.data,
      failureMessage:
          clearFailure ? null : (failureMessage ?? this.failureMessage),
    );
  }

  @override
  List<Object?> get props => [status, data, failureMessage];
}
