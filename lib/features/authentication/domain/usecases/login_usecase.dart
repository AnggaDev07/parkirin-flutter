// lib/features/authentication/domain/usecases/login_usecase.dart

import 'dart:async';
import '../repositories/i_auth_repository.dart';

class LoginUseCase {
  final IAuthRepository repository;

  LoginUseCase(this.repository);

  Future<void> call({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onVerificationCompleted,
    required Function(String) onVerificationFailed,
  }) async {
    final completer = Completer<void>();

    await repository.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: (String verificationId) {
        onCodeSent(verificationId);
        completer.complete();
      },
      onVerificationCompleted: onVerificationCompleted,
      onVerificationFailed: (String error) {
        onVerificationFailed(error);
        completer.completeError(error);
      },
    );

    await completer.future;
  }
}
