// lib/features/auth/data/datasources/firebase_auth_datasource.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Stream<UserModel?> get authStateChanges;
  UserModel? get currentUser;

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserModel> register({
    required String displayName,
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail({required String email});

  Future<void> sendVerificationEmail();

  Future<UserModel> reloadUser();

  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;
  final _log = Logger();

  @override
  Stream<UserModel?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map(
        (user) => user != null ? UserModel.fromFirebaseUser(user) : null,
      );

  @override
  UserModel? get currentUser {
    final user = _firebaseAuth.currentUser;
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return UserModel.fromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      _log.e('signInWithEmail failed', error: e);
      throw AuthException(e.code, e.message ?? '');
    }
  }

  @override
  Future<UserModel> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user!.updateDisplayName(displayName);
      await credential.user!.sendEmailVerification();
      // Reload so displayName and emailVerified are reflected immediately.
      await credential.user!.reload();
      return UserModel.fromFirebaseUser(_firebaseAuth.currentUser!);
    } on FirebaseAuthException catch (e) {
      _log.e('register failed', error: e);
      throw AuthException(e.code, e.message ?? '');
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      _log.e('sendPasswordResetEmail failed', error: e);
      throw AuthException(e.code, e.message ?? '');
    }
  }

  @override
  Future<void> sendVerificationEmail() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw const AuthException('no-current-user');
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      _log.e('sendVerificationEmail failed', error: e);
      throw AuthException(e.code, e.message ?? '');
    }
  }

  @override
  Future<UserModel> reloadUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw const AuthException('no-current-user');
      await user.reload();
      return UserModel.fromFirebaseUser(_firebaseAuth.currentUser!);
    } on FirebaseAuthException catch (e) {
      _log.e('reloadUser failed', error: e);
      throw AuthException(e.code, e.message ?? '');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      _log.e('signOut failed', error: e);
      throw AuthException(e.code, e.message ?? '');
    }
  }
}
