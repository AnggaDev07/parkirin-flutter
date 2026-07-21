// lib/features/authentication/domain/entities/user.dart
import 'package:parkirin/core/enums/user_role.dart';

class User {
  final String id;
  final String phoneNumber;
  final String email;
  final UserRole role;

  User({
    required this.id,
    required this.phoneNumber,
    required this.email,
    required this.role,
  });
}
