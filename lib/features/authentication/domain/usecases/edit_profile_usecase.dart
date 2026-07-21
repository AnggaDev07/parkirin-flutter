// lib/features/authentication/domain/usecases/edit_profile_usecase.dart

import 'package:parkirin/features/authentication/data/repositories/user_repository.dart';

class EditProfileUseCase {
  final UserRepository _userRepository;

  EditProfileUseCase(this._userRepository);

  Future<void> call({
    required String userId,
    String? name,
    String? email,
    String? phoneNumber,
  }) async {
    final updateData = <String, dynamic>{};

    if (name != null) updateData['name'] = name;
    if (email != null) updateData['email'] = email;
    if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;

    if (updateData.isNotEmpty) {
      await _userRepository.updateUser(userId, updateData);
    }
  }
}
