// lib/features/vehicle_management/domain/usecases/add_vehicle_usecase.dart

import 'package:parkirin/features/vehicle_management/domain/repositories/i_vehicle_repository.dart';

class AddVehicleUseCase {
  final IVehicleRepository repository;

  AddVehicleUseCase(this.repository);

  Future<String> call({
    required String userId,
    required String plateNumber,
    required String type,
    required String photoPath, // Changed from optional to required
  }) async {
    // Validate photo path
    if (photoPath.isEmpty) {
      throw Exception('Vehicle photo is required');
    }

    // Validate plate number format
    if (!_isValidPlateNumber(plateNumber)) {
      throw Exception('Invalid plate number format');
    }

    // Check if plate number already exists
    if (await repository.isPlateNumberExists(plateNumber)) {
      throw Exception('Plate number already registered');
    }

    // Upload photo first
    final photoUrl = await repository.uploadVehiclePhoto(
      userId: userId,
      vehicleId: 'temp', // We'll update this after creating the vehicle
      filePath: photoPath,
    );

    // Add vehicle with photo URL
    return repository.addVehicle(
      userId: userId,
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
