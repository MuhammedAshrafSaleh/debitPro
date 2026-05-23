// lib/features/settings/presentation/cubit/owner_config_state.dart

import 'package:equatable/equatable.dart';

import '../../domain/entities/owner_config_entity.dart';

abstract class OwnerConfigState extends Equatable {
  const OwnerConfigState();

  @override
  List<Object?> get props => [];
}

class OwnerConfigInitial extends OwnerConfigState {
  const OwnerConfigInitial();
}

class OwnerConfigLoading extends OwnerConfigState {
  const OwnerConfigLoading();
}

class OwnerConfigSuccess extends OwnerConfigState {
  const OwnerConfigSuccess(this.config);

  final OwnerConfigEntity config;

  @override
  List<Object?> get props => [config];
}

class OwnerConfigFailure extends OwnerConfigState {
  const OwnerConfigFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
