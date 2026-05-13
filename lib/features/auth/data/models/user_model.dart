// lib/features/auth/data/models/user_model.dart

import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/app_user.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.uid,
    required super.displayName,
    required super.email,
    required super.isEmailVerified,
    super.photoURL,
  });

  factory UserModel.fromFirebaseUser(User user) => UserModel(
        uid: user.uid,
        displayName: user.displayName ?? '',
        email: user.email ?? '',
        isEmailVerified: user.emailVerified,
        photoURL: user.photoURL,
      );

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'displayName': displayName,
        'email': email,
        'photoURL': photoURL,
        'language': 'ar',
        'darkMode': true,
        'createdAt': DateTime.now().toIso8601String(),
      };
}
