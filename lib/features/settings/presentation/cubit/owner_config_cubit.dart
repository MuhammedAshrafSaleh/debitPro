// lib/features/settings/presentation/cubit/owner_config_cubit.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/owner_config_entity.dart';
import '../../domain/usecases/get_owner_config_use_case.dart';
import '../../domain/usecases/update_owner_config_use_case.dart';
import 'owner_config_state.dart';

class OwnerConfigCubit extends Cubit<OwnerConfigState> {
  OwnerConfigCubit(this._getOwnerConfig, this._updateOwnerConfig)
      : super(const OwnerConfigInitial());

  final GetOwnerConfigUseCase _getOwnerConfig;
  final UpdateOwnerConfigUseCase _updateOwnerConfig;

  Future<void> load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    emit(const OwnerConfigLoading());
    final result = await _getOwnerConfig(uid);
    result.fold(
      (failure) => emit(OwnerConfigFailure(failure.message)),
      (config) => emit(OwnerConfigSuccess(config)),
    );
  }

  Future<bool> update({required double cardFee, required double riyalValue}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    emit(const OwnerConfigLoading());
    final result = await _updateOwnerConfig(
      UpdateOwnerConfigParams(uid: uid, cardFee: cardFee, riyalValue: riyalValue),
    );
    return result.fold(
      (failure) {
        emit(OwnerConfigFailure(failure.message));
        return false;
      },
      (_) {
        emit(OwnerConfigSuccess(
          OwnerConfigEntity(cardFee: cardFee, riyalValue: riyalValue),
        ));
        return true;
      },
    );
  }
}
