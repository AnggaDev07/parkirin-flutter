// lib/features/vehicle_management/domain/usecases/edit_vehicle_usecase.dart

import 'package:parkirin/features/vehicle_management/domain/repositories/i_vehicle_repository.dart';

class EditVehicleUseCase {
  final IVehicleRepository repository;

  EditVehicleUseCase(this.repository);

  Future<void> call({
    required String id,
    String? plateNumber,
    String? type,
    String? photoPath,
  }) async {
    // If plate number is being updated, validate it
    if (plateNumber != null) {
      // Validate plate number format
      if (!_isValidPlateNumber(plateNumber)) {
        throw Exception('Invalid plate number format');
      }

      // Get current vehicle to check if plate number is actually changing
      final currentVehicle = await repository.getVehicle(id);
      if (currentVehicle == null) {
        throw Exception('Vehicle not found');
      }

      // Only check for duplicates if the plate number is actually changing
      if (currentVehicle.plateNumber != plateNumber) {
        // Check if the new plate number is already taken by another vehicle
        if (await repository.isPlateNumberExists(plateNumber)) {
          throw Exception('Plate number already registered');
        }
      }
    }

    String? photoUrl;
    if (photoPath != null) {
      // Get vehicle first to get user ID
      final vehicle = await repository.getVehicle(id);
      if (vehicle == null) {
        throw Exception('Vehicle not found');
      }

      // Upload new photo
      photoUrl = await repository.uploadVehiclePhoto(
        userId: vehicle.userId,
        vehicleId: id,
        filePath: photoPath,
      );
    }

    // Update vehicle with new data
    await repository.updateVehicle(
      id: id,
      plateNumber: plateNumber,
      type: type,
      photoUrl: photoUrl,
    );
  }

  bool _isValidPlateNumber(String plateNumber) {
    // Indonesian license plate format: AA 1234 BB
    final regex = RegExp(r'^[A-Z]{1,2}\s?\d{1,4}\s?[A-Z]{1,3}$');
    return regex.hasMatch(plateNumber);
  }
}
