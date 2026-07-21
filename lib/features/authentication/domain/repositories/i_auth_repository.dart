// lib/features/authentication/domain/repositories/i_auth_repository.dart

import 'package:parkirin/core/enums/user_role.dart';

abstract class IAuthRepository {
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onVerificationCompleted,
    required Function(String) onVerificationFailed,
  });

  Future<User> signInWithOTP(String verificationId, String otp);
  Future<User?> loginParkingAttendant(String nijp, String password);
  Future<void> signOut();
  Future<User?> signInWithGoogle({bool silentSignIn = false});

  Stream<User?> get authStateChanges;
}

class User {
  final String id;
  final String phoneNumber;
  final String email;
  final UserRole role;

  User(
      {required this.id,
      required this.phoneNumber,
      required this.email,
      required this.role});
}
