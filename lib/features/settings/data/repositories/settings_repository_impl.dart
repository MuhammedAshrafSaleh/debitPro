// lib/features/settings/data/repositories/settings_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/firebase_user_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._dataSource, this._networkInfo);

  final SettingsRemoteDataSource _dataSource;
  final NetworkInfo _networkInfo;
  final _log = Logger();

  Future<Either<Failure, T>?> _checkNetwork<T>() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    return null;
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> loadPreferences(
    String uid,
  ) async {
    try {
      final prefs = await _dataSource.loadPreferences(uid);
      return Right(prefs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveLanguage({
    required String uid,
    required String languageCode,
  }) async {
    final offline = await _checkNetwork<void>();
    if (offline != null) return offline;
    try {
      await _dataSource.saveLanguage(uid: uid, languageCode: languageCode);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveDarkMode({
    required String uid,
    required bool isDark,
  }) async {
    final offline = await _checkNetwork<void>();
    if (offline != null) return offline;
    try {
      await _dataSource.saveDarkMode(uid: uid, isDark: isDark);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateDisplayName(String displayName) async {
    final offline = await _checkNetwork<void>();
    if (offline != null) return offline;
    try {
      await _dataSource.updateDisplayName(displayName);
      return const Right(null);
    } on AuthException catch (e) {
      _log.e('updateDisplayName', error: e);
      return Left(AuthFailure(_mapAuthCode(e.code)));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateEmail({
    required String newEmail,
    required String currentPassword,
  }) async {
    final offline = await _checkNetwork<void>();
    if (offline != null) return offline;
    try {
      await _dataSource.updateEmail(
        newEmail: newEmail,
        currentPassword: currentPassword,
      );
      return const Right(null);
    } on AuthException catch (e) {
      _log.e('updateEmail', error: e);
      return Left(AuthFailure(_mapAuthCode(e.code)));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final offline = await _checkNetwork<void>();
    if (offline != null) return offline;
    try {
      await _dataSource.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } on AuthException catch (e) {
      _log.e('updatePassword', error: e);
      return Left(AuthFailure(_mapAuthCode(e.code)));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  String _mapAuthCode(String code) {
    switch (code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'كلمة المرور الحالية غير صحيحة';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'no-current-user':
        return 'لا يوجد مستخدم مسجّل الدخول';
      case 'weak-password':
        return 'كلمة المرور ضعيفة، يجب أن تكون 6 أحرف على الأقل';
      case 'too-many-requests':
        return 'طلبات كثيرة جداً، يرجى المحاولة لاحقاً';
      default:
        return 'حدث خطأ في العملية';
    }
  }
}
