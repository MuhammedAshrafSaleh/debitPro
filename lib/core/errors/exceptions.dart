// lib/core/errors/exceptions.dart

class ServerException implements Exception {
  const ServerException([this.message = 'حدث خطأ في الخادم']);
  final String message;

  @override
  String toString() => 'ServerException: $message';
}

class NetworkException implements Exception {
  const NetworkException([this.message = 'لا يوجد اتصال بالإنترنت']);
  final String message;
}

class AuthException implements Exception {
  const AuthException(this.code, [this.message = '']);
  final String code;
  final String message;
}

class PermissionException implements Exception {
  const PermissionException([this.message = 'ليس لديك صلاحية للقيام بهذا الإجراء']);
  final String message;
}

class CacheException implements Exception {
  const CacheException([this.message = 'حدث خطأ في التخزين المؤقت']);
  final String message;
}

class AlreadyPaidException implements Exception {
  const AlreadyPaidException([this.message = 'تم دفع هذه الدفعة مسبقاً']);
  final String message;

  @override
  String toString() => 'AlreadyPaidException: $message';
}

class EditLockedException implements Exception {
  const EditLockedException([this.message = 'لا يمكن تعديل هذا السجل بعد أول دفعة']);
  final String message;

  @override
  String toString() => 'EditLockedException: $message';
}
