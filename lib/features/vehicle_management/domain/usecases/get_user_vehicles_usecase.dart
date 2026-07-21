// lib/features/vehicle_management/domain/usecases/get_user_vehicles_usecase.dart

import 'package:parkirin/features/vehicle_management/domain/entities/vehicle.dart';
import 'package:parkirin/features/vehicle_management/domain/repositories/i_vehicle_repository.dart';

class GetUserVehiclesUseCase {
  final IVehicleRepository repository;

  GetUserVehiclesUseCase(this.repository);

  Future<List<Vehicle>> call(String userId) {
    return repository.getUserVehicles(userId);
  }
}
