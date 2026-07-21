// lib/features/authentication/domain/usecases/login_parking_attendant_usecase.dart
import '../repositories/i_auth_repository.dart';

class LoginParkingAttendantUseCase {
  final IAuthRepository repository;

  LoginParkingAttendantUseCase(this.repository);

  Future<User?> call(String nijp, String password) async {
    return await repository.loginParkingAttendant(nijp, password);
  }
}
