// lib/features/authentication/presentation/bloc/auth_bloc.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkirin/core/enums/user_role.dart';
import 'package:parkirin/core/services/session_service.dart';
import 'package:parkirin/features/authentication/domain/usecases/google_sign_in_usecase.dart';
import 'package:parkirin/features/authentication/domain/usecases/login_parking_attendant_usecase.dart';

import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';

// Events
abstract class AuthEvent {}

class PhoneNumberSubmitted extends AuthEvent {
  final String phoneNumber;
  PhoneNumberSubmitted(this.phoneNumber);
}

class SessionRestoredEvent extends AuthEvent {
  final User user;
  SessionRestoredEvent(this.user);
}

class GoogleSignInRequested extends AuthEvent {}

class ManualOtpSubmitted extends AuthEvent {
  final String otp;
  final String verificationId;
  ManualOtpSubmitted(this.otp, this.verificationId);
}

class OtpSubmitted extends AuthEvent {
  final String otp;
  OtpSubmitted(this.otp);
}

class RoleSelected extends AuthEvent {
  final UserRole role;
  RoleSelected(this.role);
}

class ParkingAttendantLoginSubmitted extends AuthEvent {
  final String nijp;
  final String password;
  ParkingAttendantLoginSubmitted(this.nijp, this.password);
}

class SignOutRequested extends AuthEvent {}

// States
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {
  final String message;
  final String? step;

  AuthLoading({
    required this.message,
    this.step,
  });
}

class AuthOtpLoading extends AuthLoading {
  AuthOtpLoading() : super(message: 'Sending OTP code...');
}

class AuthOtpVerifying extends AuthLoading {
  AuthOtpVerifying() : super(message: 'Verifying OTP code...');
}

class AuthGoogleLoading extends AuthLoading {
  AuthGoogleLoading() : super(message: 'Signing in with Google...');
}

class AuthParkingAttendantLoading extends AuthLoading {
  AuthParkingAttendantLoading() : super(message: 'Verifying credentials...');
}

class AuthRoleChanged extends AuthState {
  final UserRole role;
  AuthRoleChanged(this.role);
}

class OtpSentState extends AuthState {
  final String verificationId;
  OtpSentState(this.verificationId);
}

class AuthSuccess extends AuthState {
  final User user;
  AuthSuccess(this.user);
}

class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final IAuthRepository _authRepository;
  final LoginParkingAttendantUseCase _loginParkingAttendantUseCase;
  final GoogleSignInUseCase _googleSignInUseCase;
  final SessionService _sessionService;
  String? _verificationId;
  UserRole _selectedRole = UserRole.driver;
  UserRole get selectedRole => _selectedRole;

  AuthBloc(
    this._loginUseCase,
    this._authRepository,
    this._googleSignInUseCase,
    this._loginParkingAttendantUseCase,
    this._sessionService,
  ) : super(AuthInitial()) {
    on<PhoneNumberSubmitted>(_onPhoneNumberSubmitted);
    on<OtpSubmitted>(_onOtpSubmitted);
    on<ManualOtpSubmitted>(_onManualOtpSubmitted);
    on<SignOutRequested>(_onSignOutRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<RoleSelected>(_onRoleSelected);
    on<ParkingAttendantLoginSubmitted>(_onParkingAttendantLoginSubmitted);
    on<SessionRestoredEvent>(_onSessionRestored);
  }

  void checkSession() {
    final user = _sessionService.getUser();
    if (user != null) {
      add(SessionRestoredEvent(user));
    }
  }

  void _onSessionRestored(
    SessionRestoredEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthSuccess(event.user));
  }

  Future<void> _onSignOutRequested(
      SignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading(message: ''));
    try {
      await _authRepository.signOut();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  void _onRoleSelected(RoleSelected event, Emitter<AuthState> emit) {
    debugPrint('Role selected: ${event.role}');
    _selectedRole = event.role;
    emit(AuthRoleChanged(_selectedRole));
  }

  Future<void> _onParkingAttendantLoginSubmitted(
      ParkingAttendantLoginSubmitted event, Emitter<AuthState> emit) async {
    emit(
        AuthParkingAttendantLoading()); // Changed from AuthParkingAttendantSigningIn
    try {
      final user = await _loginParkingAttendantUseCase(
        event.nijp,
        event.password,
      );
      if (user != null) {
        emit(AuthSuccess(user));
      } else {
        emit(AuthFailure('Invalid NIJP or password. Please try again.'));
        emit(AuthInitial());
      }
    } catch (e) {
      emit(AuthFailure('Login failed: ${e.toString()}'));
      emit(AuthInitial());
    }
  }

  Future<void> _onGoogleSignInRequested(
      GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthGoogleLoading()); // Changed from AuthGoogleSigningIn()
    try {
      final user = await _googleSignInUseCase(silentSignIn: false);
      if (user != null) {
        emit(AuthSuccess(user));
      } else {
        emit(AuthFailure('Google Sign-In failed. Please try again.'));
        // Return to initial state to allow another attempt
        emit(AuthInitial());
      }
    } catch (e) {
      emit(AuthFailure('Google Sign-In failed: ${e.toString()}'));
      emit(AuthInitial());
    }
  }

  Future<void> _onPhoneNumberSubmitted(
      PhoneNumberSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthOtpLoading()); // Changed from AuthOtpSending
    try {
      await _loginUseCase(
        phoneNumber: event.phoneNumber,
        onCodeSent: (String verificationId) {
          emit(OtpSentState(verificationId));
        },
        onVerificationCompleted: (String smsCode) {
          emit(AuthOtpVerifying());
          add(OtpSubmitted(smsCode));
        },
        onVerificationFailed: (String error) {
          emit(AuthFailure(error));
        },
      );
    } catch (e) {
      emit(AuthFailure('Failed to send OTP: ${e.toString()}'));
    }
  }

  void _onOtpSubmitted(OtpSubmitted event, Emitter<AuthState> emit) async {
    if (_verificationId == null) {
      debugPrint('Verification ID is null. Cannot submit OTP.');
      emit(AuthFailure('Verification ID is null'));
      return;
    }
    emit(AuthOtpVerifying()); // Changed from AuthLoading
    try {
      debugPrint('Attempting to sign in with OTP: ${event.otp}');
      final user =
          await _authRepository.signInWithOTP(_verificationId!, event.otp);
      debugPrint('User signed in successfully. User ID: ${user.id}');
      emit(AuthSuccess(user));
    } catch (e) {
      debugPrint('Exception during OTP submission: $e');
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onManualOtpSubmitted(
      ManualOtpSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthOtpVerifying());
    try {
      final user = await _authRepository.signInWithOTP(
        event.verificationId,
        event.otp,
      );
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure('Invalid OTP. Please try again.'));
      // Optionally re-emit the OtpSentState to allow another attempt
      emit(OtpSentState(event.verificationId));
    }
  }
}
