import '../repositories/i_auth_repository.dart';

class GoogleSignInUseCase {
  final IAuthRepository repository;

  GoogleSignInUseCase(this.repository);

  Future<User?> call({bool silentSignIn = false}) async {
    return await repository.signInWithGoogle(silentSignIn: silentSignIn);
  }
}
