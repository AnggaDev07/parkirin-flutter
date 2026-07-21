import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:parkirin/core/enums/user_role.dart';
import 'package:parkirin/core/services/session_service.dart';
import 'package:parkirin/core/utils/password_utils.dart';
import 'package:parkirin/features/authentication/data/repositories/user_repository.dart';
import 'package:parkirin/features/authentication/domain/entities/user_model.dart';

import '../../domain/repositories/i_auth_repository.dart';

class FirebaseAuthRepository implements IAuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final UserRepository _userRepository;
  final SessionService _sessionService;

  FirebaseAuthRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    UserRepository? userRepository,
    required SessionService sessionService, // Add this parameter
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _userRepository = userRepository ?? UserRepository(),
        _sessionService = sessionService;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onVerificationCompleted,
    required Function(String) onVerificationFailed,
  }) async {
    debugPrint('Verifying phone number: $phoneNumber');
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 120), // Increase timeout to 120 seconds
      verificationCompleted:
          (firebase_auth.PhoneAuthCredential credential) async {
        debugPrint('Verification completed automatically');
        await _firebaseAuth.signInWithCredential(credential);
        onVerificationCompleted(credential.smsCode ?? '');
      },
      verificationFailed: (firebase_auth.FirebaseAuthException e) {
        debugPrint('Verification failed: ${e.message}');
        onVerificationFailed(e.message ?? 'Verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        debugPrint('Code sent. Verification ID: $verificationId');
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        debugPrint(
            'Code auto retrieval timeout. Verification ID: $verificationId');
      },
    );
  }

  @override
  Future<User> signInWithOTP(String verificationId, String otp) async {
    try {
      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final userModel = UserModel(
        id: userCredential.user!.uid,
        phoneNumber: userCredential.user!.phoneNumber ?? '',
        email: userCredential.user!.email,
        role: UserRole.driver,
        points: 0,
        vehicles: [],
        totalBills: 0,
      );

      final existingUser = await _userRepository.getUser(userModel.id);
      if (existingUser == null) {
        await _userRepository.createUser(userModel);
      }

      final user = User(
        id: userModel.id,
        phoneNumber: userModel.phoneNumber,
        email: userModel.email ?? '',
        role: userModel.role,
      );

      // Save session for OTP Sign-In
      await _sessionService.saveUser(user);

      return user;
    } catch (e) {
      throw Exception('Failed to sign in with OTP: $e');
    }
  }

  @override
  Future<User?> loginParkingAttendant(String nijp, String password) async {
    try {
      final attendant = await _userRepository.getParkingAttendant(nijp);

      if (attendant == null) {
        throw Exception('Invalid NIJP');
      }

      if (!PasswordUtils.verifyPassword(password, attendant.password)) {
        throw Exception('Invalid password');
      }

      final user = User(
        id: nijp,
        phoneNumber: attendant.phoneNumber ?? '',
        email: attendant.email ?? '',
        role: UserRole.parkingAttendant,
      );

      // Save session
      await _sessionService.saveUser(user);

      return user;
    } catch (e) {
      debugPrint('Error during Parking Attendant login: $e');
      return null;
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) {
        debugPrint('Auth state changed: User is null');
        return null;
      } else {
        debugPrint('Auth state changed: User ID ${firebaseUser.uid}');
        return User(
          id: firebaseUser.uid,
          phoneNumber: firebaseUser.phoneNumber ?? '',
          email: firebaseUser.email ?? '',
          role: UserRole.driver,
        );
      }
    });
  }

  @override
  Future<void> signOut() async {
    debugPrint('Signing out');
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
      _sessionService.clearSession(),
    ]);
    debugPrint('Signed out successfully');
  }

  @override
  Future<User?> signInWithGoogle({bool silentSignIn = false}) async {
    try {
      final googleUser = silentSignIn
          ? await _googleSignIn.signInSilently()
          : await _googleSignIn.signIn();

      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final userModel = UserModel(
        id: userCredential.user!.uid,
        phoneNumber: userCredential.user!.phoneNumber ?? '',
        email: userCredential.user!.email,
        name: userCredential.user!.displayName,
        role: UserRole.driver,
      );

      final existingUser = await _userRepository.getUser(userModel.id);
      if (existingUser == null) {
        await _userRepository.createUser(userModel);
      }

      final user = User(
        id: userModel.id,
        phoneNumber: userModel.phoneNumber,
        email: userModel.email ?? '',
        role: userModel.role,
      );

      // Save session for Google Sign-In
      await _sessionService.saveUser(user);

      return user;
    } catch (e) {
      debugPrint('Error during Google Sign-In: $e');
      return null;
    }
  }
}
