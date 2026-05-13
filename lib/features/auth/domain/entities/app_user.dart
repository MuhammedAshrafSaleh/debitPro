// lib/features/auth/domain/entities/app_user.dart

import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.isEmailVerified,
    this.photoURL,
  });

  final String uid;
  final String displayName;
  final String email;
  final bool isEmailVerified;
  final String? photoURL;

  @override
  List<Object?> get props => [uid, displayName, email, isEmailVerified, photoURL];
}
