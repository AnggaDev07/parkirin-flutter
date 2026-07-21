// lib/features/vehicle_management/domain/repositories/i_vehicle_repository.dart

import '../entities/vehicle.dart';

abstract class IVehicleRepository {
  Future<String> addVehicle({
    required String userId,
    required String plateNumber,
    required String type,
    String? photoUrl,
  });

  Future<List<Vehicle>> getUserVehicles(String userId);

  Future<Vehicle?> getVehicle(String id);

  Future<Vehicle?> findVehicleByPlateNumber(String plateNumber);

  Future<void> updateVehicle({
    required String id,
    String? plateNumber,
    String? type,
    String? photoUrl,
  });

  Future<void> deleteVehicle(String id);

  Future<bool> isPlateNumberExists(String plateNumber);

  Future<String> uploadVehiclePhoto({
    required String userId,
    required String vehicleId,
    required String filePath,
  });
}
