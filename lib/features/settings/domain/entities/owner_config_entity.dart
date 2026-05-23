// lib/features/settings/domain/entities/owner_config_entity.dart

import 'package:equatable/equatable.dart';

class OwnerConfigEntity extends Equatable {
  const OwnerConfigEntity({
    required this.cardFee,
    required this.riyalValue,
  });

  final double cardFee;
  final double riyalValue;

  static const empty = OwnerConfigEntity(cardFee: 0.0, riyalValue: 0.0);

  @override
  List<Object?> get props => [cardFee, riyalValue];
}
