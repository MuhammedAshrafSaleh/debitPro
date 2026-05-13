// lib/core/errors/failures.dart

import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'حدث خطأ في الخادم']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'لا يوجد اتصال بالإنترنت']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'فشل المصادقة']);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'ليس لديك صلاحية للقيام بهذا الإجراء']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'بيانات غير صالحة']);
}

class EditLockedFailure extends Failure {
  const EditLockedFailure([super.message = 'لا يمكن تعديل هذا السجل بعد أول دفعة']);
}

class AlreadyPaidFailure extends Failure {
  const AlreadyPaidFailure([super.message = 'تم دفع هذه الدفعة مسبقاً']);
}
