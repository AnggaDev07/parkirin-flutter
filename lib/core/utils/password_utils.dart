// lib/core/utils/password_utils.dart

import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:crypto/crypto.dart';

enum HashType { sha256, bcrypt }

class PasswordUtils {
  // Hash password using specified algorithm
  static String hashPassword(String password,
      {HashType type = HashType.bcrypt}) {
    switch (type) {
      case HashType.bcrypt:
        return BCrypt.hashpw(password, BCrypt.gensalt());
      case HashType.sha256:
        final bytes = utf8.encode(password);
        return sha256.convert(bytes).toString();
    }
  }

  // Verify password against hash
  static bool verifyPassword(String password, String hash) {
    // Check if it's a bcrypt hash (starts with $2a$, $2b$, or $2y$)
    if (hash.startsWith(RegExp(r'\$2[aby]\$'))) {
      return BCrypt.checkpw(password, hash);
    }
    // Fallback to SHA-256
    else {
      return hashPassword(password, type: HashType.sha256) == hash;
    }
  }
}
