// lib/core/services/session_service.dart

import 'dart:convert';

import 'package:parkirin/core/enums/user_role.dart';
import 'package:parkirin/features/authentication/domain/repositories/i_auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _keyUser = 'user';
  final SharedPreferences _prefs;

  SessionService(this._prefs);

  Future<void> saveUser(User user) async {
    final userData = {
      'id': user.id,
      'phoneNumber': user.phoneNumber,
      'email': user.email,
      'role': user.role.toString(),
    };
    await _prefs.setString(_keyUser, jsonEncode(userData));
  }

  Future<void> clearSession() async {
    await _prefs.remove(_keyUser);
  }

  User? getUser() {
    final userStr = _prefs.getString(_keyUser);
    if (userStr == null) return null;

    final userData = jsonDecode(userStr) as Map<String, dynamic>;
    return User(
      id: userData['id'],
      phoneNumber: userData['phoneNumber'],
      email: userData['email'],
      role: userData['role'] == 'UserRole.driver'
          ? UserRole.driver
          : UserRole.parkingAttendant,
    );
  }

  bool get isLoggedIn => _prefs.containsKey(_keyUser);
}
