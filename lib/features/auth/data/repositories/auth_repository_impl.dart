// lib/features/auth/data/repositories/auth_repository_impl.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource, this._firestore);

  final AuthRemoteDataSource _dataSource;
  final FirebaseFirestore _firestore;
  final _log = Logger();

  @override
  Stream<AppUser?> get authStateChanges => _dataSource.authStateChanges;

  @override
  AppUser? get currentUser => _dataSource.currentUser;

  @override
  Future<Either<Failure, AppUser>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _dataSource.signInWithEmail(
        email: email,
        password: password,
      );
      await _ensureUserProfile(user);
      return Right(user);
    } on AuthException catch (e) {
      _log.e('signInWithEmail', error: e);
      return Left(AuthFailure(_mapAuthCode(e.code)));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, AppUser>> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    try {
      final user = await _dataSource.register(
        displayName: displayName,
        email: email,
        password: password,
      );
      await _createUserProfile(user);
      return Right(user);
    } on AuthException catch (e) {
      _log.e('register', error: e);
      return Left(AuthFailure(_mapAuthCode(e.code)));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _dataSource.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on AuthException catch (e) {
      _log.e('sendPasswordResetEmail', error: e);
      return Left(AuthFailure(_mapAuthCode(e.code)));
    }
  }

  @override
  Future<Either<Failure, void>> sendVerificationEmail() async {
    try {
      await _dataSource.sendVerificationEmail();
      return const Right(null);
    } on AuthException catch (e) {
      _log.e('sendVerificationEmail', error: e);
      return Left(AuthFailure(_mapAuthCode(e.code)));
    }
  }

  @override
  Future<Either<Failure, AppUser>> reloadUser() async {
    try {
      final user = await _dataSource.reloadUser();
      return Right(user);
    } on AuthException catch (e) {
      _log.e('reloadUser', error: e);
      return Left(AuthFailure(_mapAuthCode(e.code)));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _dataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      _log.e('signOut', error: e);
      return Left(AuthFailure(_mapAuthCode(e.code)));
    }
  }

  Future<void> _createUserProfile(UserModel user) async {
    try {
      await _firestore
          .doc(FirestorePaths.users(user.uid))
          .set(user.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      _log.e('_createUserProfile', error: e);
    }
  }

  // Called on sign-in: creates the document if missing but does NOT overwrite
  // language/darkMode so existing preferences are preserved.
  Future<void> _ensureUserProfile(UserModel user) async {
    try {
      final doc = await _firestore.doc(FirestorePaths.users(user.uid)).get();
      if (!doc.exists) {
        await _firestore
            .doc(FirestorePaths.users(user.uid))
            .set(user.toFirestore(), SetOptions(merge: true));
      }
    } catch (e) {
      _log.e('_ensureUserProfile', error: e);
    }
  }

  String _mapAuthCode(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'weak-password':
        return 'كلمة المرور ضعيفة، يجب أن تكون 6 أحرف على الأقل';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'too-many-requests':
        return 'طلبات كثيرة جداً، يرجى المحاولة لاحقاً';
      case 'user-disabled':
        return 'هذا الحساب معطّل';
      case 'no-current-user':
        return 'لا يوجد مستخدم مسجّل الدخول';
      default:
        return 'حدث خطأ في المصادقة';
    }
  }
}
