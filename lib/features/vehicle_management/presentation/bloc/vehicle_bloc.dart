// lib/features/vehicle_management/presentation/bloc/vehicle_bloc.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/add_vehicle_usecase.dart';
import '../../domain/usecases/edit_vehicle_usecase.dart';
import '../../domain/usecases/get_user_vehicles_usecase.dart';
import '../../domain/usecases/upload_vehicle_photo_usecase.dart';
import 'vehicle_event.dart';
import 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final AddVehicleUseCase _addVehicleUseCase;
  final GetUserVehiclesUseCase _getUserVehiclesUseCase;
  final UploadVehiclePhotoUseCase _uploadVehiclePhotoUseCase;
  final EditVehicleUseCase _editVehicleUseCase;

  VehicleBloc({
    required AddVehicleUseCase addVehicleUseCase,
    required GetUserVehiclesUseCase getUserVehiclesUseCase,
    required UploadVehiclePhotoUseCase uploadVehiclePhotoUseCase,
    required EditVehicleUseCase editVehicleUseCase,
  })  : _addVehicleUseCase = addVehicleUseCase,
        _getUserVehiclesUseCase = getUserVehiclesUseCase,
        _uploadVehiclePhotoUseCase = uploadVehiclePhotoUseCase,
        _editVehicleUseCase = editVehicleUseCase,
        super(VehicleInitial()) {
    on<LoadUserVehicles>(_onLoadUserVehicles);
    on<AddVehicleEvent>(_onAddVehicle);
    on<DeleteVehicleEvent>(_onDeleteVehicle);
    on<EditVehicleEvent>(_onEditVehicle);
  }

  Future<void> _onLoadUserVehicles(
    LoadUserVehicles event,
    Emitter<VehicleState> emit,
  ) async {
    debugPrint('[VehicleBloc] Starting to load vehicles...');
    emit(VehicleLoading());
    try {
      final vehicles = await _getUserVehiclesUseCase(event.userId);
      debugPrint('[VehicleBloc] Loaded ${vehicles.length} vehicles');

      // Only log first vehicle details if list is not empty
      if (vehicles.isNotEmpty) {
        debugPrint(
            '[VehicleBloc] First vehicle photo URL: ${vehicles.first.photoUrl}');
      }

      emit(VehiclesLoaded(vehicles));
    } catch (e) {
      debugPrint('[VehicleBloc] Error loading vehicles: $e');
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onAddVehicle(
    AddVehicleEvent event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());
    try {
      // Validate photo path is provided
      if (event.photoPath == null) {
        emit(const VehicleError('Vehicle photo is required'));
        return;
      }
      String? photoUrl;
      String vehicleId;

      // First upload the photo
      photoUrl = await _uploadVehiclePhotoUseCase(
        userId: event.userId,
        vehicleId:
            'temp', // Temporary ID since we haven't created the vehicle yet
        filePath: event.photoPath!,
      );

      // Then add the vehicle with the photo URL
      vehicleId = await _addVehicleUseCase(
        userId: event.userId,
        plateNumber: event.plateNumber,
        type: event.type,
        photoPath: event.photoPath!, // Now required
      );

      // If photo path is provided, upload it
      if (event.photoPath != null) {
        photoUrl = await _uploadVehiclePhotoUseCase(
          userId: event.userId,
          vehicleId: vehicleId,
          filePath: event.photoPath!,
        );

        // Update vehicle with photo URL
        await _addVehicleUseCase.repository.updateVehicle(
          id: vehicleId,
          photoUrl: photoUrl,
        );
      }

      // Reload user vehicles
      final vehicles = await _getUserVehiclesUseCase(event.userId);
      emit(VehiclesLoaded(vehicles));
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onEditVehicle(
    EditVehicleEvent event,
    Emitter<VehicleState> emit,
  ) async {
    debugPrint('Starting edit vehicle process...');
    emit(VehicleLoading());

    try {
      String? photoUrl;
      if (event.photoPath != null) {
        debugPrint('Uploading new photo...');
        // Get the vehicle first to get userId
        final vehicle =
            await _editVehicleUseCase.repository.getVehicle(event.id);
        if (vehicle == null) {
          throw Exception('Vehicle not found');
        }

        // Upload new photo
        photoUrl = await _uploadVehiclePhotoUseCase(
          userId: vehicle.userId,
          vehicleId: event.id,
          filePath: event.photoPath!,
        );
        debugPrint('Photo uploaded successfully: $photoUrl');
      }

      debugPrint('Updating vehicle data...');
      // Update vehicle using editVehicleUseCase
      await _editVehicleUseCase(
        id: event.id,
        plateNumber: event.plateNumber,
        type: event.type,
        photoPath: event.photoPath,
      );

      debugPrint('Vehicle updated, fetching vehicle list...');
      // Get updated vehicle data using editVehicleUseCase
      final vehicle = await _editVehicleUseCase.repository.getVehicle(event.id);
      if (vehicle != null) {
        final vehicles = await _getUserVehiclesUseCase(vehicle.userId);
        debugPrint(
            'Emitting VehiclesLoaded state with ${vehicles.length} vehicles');
        emit(VehiclesLoaded(vehicles));
      } else {
        throw Exception('Failed to fetch updated vehicle');
      }
    } catch (e) {
      debugPrint('Error during edit: $e');
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onDeleteVehicle(
    DeleteVehicleEvent event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      // Get current list before deletion
      if (state is VehiclesLoaded) {
        final currentVehicles = (state as VehiclesLoaded).vehicles;
        // Emit optimistic update
        emit(VehiclesLoaded(
          currentVehicles.where((v) => v.id != event.vehicleId).toList(),
        ));
      }

      // Perform deletion
      await _addVehicleUseCase.repository.deleteVehicle(event.vehicleId);

      // No need to emit VehicleDeleted state as we've already updated the list
    } catch (e) {
      emit(VehicleError(e.toString()));
      // Reload vehicles to ensure consistency
      if (state is VehiclesLoaded) {
        final userId = (state as VehiclesLoaded).vehicles.first.userId;
        final vehicles = await _getUserVehiclesUseCase(userId);
        emit(VehiclesLoaded(vehicles));
      }
    }
  }
}
