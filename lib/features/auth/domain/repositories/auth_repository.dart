// lib/features/auth/domain/repositories/auth_repository.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  AppUser? get currentUser;

  Future<Either<Failure, AppUser>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, AppUser>> register({
    required String displayName,
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> sendPasswordResetEmail({required String email});

  Future<Either<Failure, void>> sendVerificationEmail();

  Future<Either<Failure, AppUser>> reloadUser();

  Future<Either<Failure, void>> signOut();
}
