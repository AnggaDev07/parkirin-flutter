// lib/features/vehicle_management/domain/usecases/upload_vehicle_photo_usecase.dart

import 'package:parkirin/features/vehicle_management/domain/repositories/i_vehicle_repository.dart';

class UploadVehiclePhotoUseCase {
  final IVehicleRepository repository;

  UploadVehiclePhotoUseCase(this.repository);

  Future<String> call({
    required String userId,
    required String vehicleId,
    required String filePath,
  }) {
    return repository.uploadVehiclePhoto(
      userId: userId,
      vehicleId: vehicleId,
      filePath: filePath,
    );
  }
}
