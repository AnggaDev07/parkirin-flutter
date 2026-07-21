// lib/features/authentication/presentation/bloc/profile_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkirin/features/authentication/domain/usecases/edit_profile_usecase.dart';

// Events
abstract class ProfileEvent {}

class ProfileEditRequested extends ProfileEvent {
  final String userId;
  final String? name;
  final String? email;
  final String? phoneNumber;

  ProfileEditRequested({
    required this.userId,
    this.name,
    this.email,
    this.phoneNumber,
  });
}

// States
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {}

class ProfileUpdateFailure extends ProfileState {
  final String error;
  ProfileUpdateFailure(this.error);
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final EditProfileUseCase _editProfileUseCase;

  ProfileBloc({
    required EditProfileUseCase editProfileUseCase,
  })  : _editProfileUseCase = editProfileUseCase,
        super(ProfileInitial()) {
    on<ProfileEditRequested>(_onProfileEditRequested);
  }

  Future<void> _onProfileEditRequested(
    ProfileEditRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    try {
      await _editProfileUseCase(
        userId: event.userId,
        name: event.name,
        email: event.email,
        phoneNumber: event.phoneNumber,
      );
      emit(ProfileUpdateSuccess());
    } catch (e) {
      emit(ProfileUpdateFailure(e.toString()));
    }
  }
}
