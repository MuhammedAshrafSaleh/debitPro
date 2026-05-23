// lib/features/settings/data/datasources/firebase_user_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/errors/exceptions.dart';

abstract class SettingsRemoteDataSource {
  Future<Map<String, dynamic>> loadPreferences(String uid);
  Future<void> saveLanguage({required String uid, required String languageCode});
  Future<void> saveDarkMode({required String uid, required bool isDark});
  Future<void> updateDisplayName(String displayName);
  Future<void> updateEmail({
    required String newEmail,
    required String currentPassword,
  });
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<Map<String, dynamic>> getOwnerConfig(String uid);
  Future<void> updateOwnerConfig({
    required String uid,
    required double cardFee,
    required double riyalValue,
  });
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  SettingsRemoteDataSourceImpl(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final _log = Logger();

  @override
  Future<Map<String, dynamic>> loadPreferences(String uid) async {
    try {
      final doc = await _firestore.doc(FirestorePaths.users(uid)).get();
      final data = doc.data();
      if (data == null) return {'language': 'ar', 'darkMode': true};
      return {
        'language': data['language'] as String? ?? 'ar',
        'darkMode': data['darkMode'] as bool? ?? true,
      };
    } catch (e) {
      _log.e('loadPreferences', error: e);
      throw const ServerException();
    }
  }

  @override
  Future<void> saveLanguage({
    required String uid,
    required String languageCode,
  }) async {
    try {
      await _firestore
          .doc(FirestorePaths.users(uid))
          .set({'language': languageCode}, SetOptions(merge: true));
    } catch (e) {
      _log.e('saveLanguage', error: e);
      throw const ServerException();
    }
  }

  @override
  Future<void> saveDarkMode({required String uid, required bool isDark}) async {
    try {
      await _firestore
          .doc(FirestorePaths.users(uid))
          .set({'darkMode': isDark}, SetOptions(merge: true));
    } catch (e) {
      _log.e('saveDarkMode', error: e);
      throw const ServerException();
    }
  }

  @override
  Future<void> updateDisplayName(String displayName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw const AuthException('no-current-user');
      await user.updateDisplayName(displayName);
      await user.reload();
    } on FirebaseAuthException catch (e) {
      _log.e('updateDisplayName', error: e);
      throw AuthException(e.code, e.message ?? '');
    } catch (e) {
      if (e is AuthException) rethrow;
      _log.e('updateDisplayName', error: e);
      throw const ServerException();
    }
  }

  @override
  Future<void> updateEmail({
    required String newEmail,
    required String currentPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw const AuthException('no-current-user');
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.verifyBeforeUpdateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      _log.e('updateEmail', error: e);
      throw AuthException(e.code, e.message ?? '');
    }
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw const AuthException('no-current-user');
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      _log.e('updatePassword', error: e);
      throw AuthException(e.code, e.message ?? '');
    }
  }

  @override
  Future<Map<String, dynamic>> getOwnerConfig(String uid) async {
    try {
      final doc = await _firestore.doc(FirestorePaths.users(uid)).get();
      final data = doc.data();
      return {
        'cardFee': (data?['cardFee'] as num?)?.toDouble() ?? 0.0,
        'riyalValue': (data?['riyalValue'] as num?)?.toDouble() ?? 0.0,
      };
    } catch (e) {
      _log.e('getOwnerConfig', error: e);
      throw const ServerException();
    }
  }

  @override
  Future<void> updateOwnerConfig({
    required String uid,
    required double cardFee,
    required double riyalValue,
  }) async {
    try {
      await _firestore.doc(FirestorePaths.users(uid)).set(
        {'cardFee': cardFee, 'riyalValue': riyalValue},
        SetOptions(merge: true),
      );
    } catch (e) {
      _log.e('updateOwnerConfig', error: e);
      throw const ServerException();
    }
  }
}
