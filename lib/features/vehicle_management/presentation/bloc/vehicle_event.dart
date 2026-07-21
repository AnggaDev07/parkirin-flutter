// lib/features/vehicle_management/presentation/bloc/vehicle_event.dart

import 'package:equatable/equatable.dart';

abstract class VehicleEvent extends Equatable {
  const VehicleEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserVehicles extends VehicleEvent {
  final String userId;
  const LoadUserVehicles(this.userId);

  @override
  List<Object> get props => [userId];
}

class AddVehicleEvent extends VehicleEvent {
  final String userId;
  final String plateNumber;
  final String type;
  final String? photoPath;

  const AddVehicleEvent({
    required this.userId,
    required this.plateNumber,
    required this.type,
    this.photoPath,
  });

  @override
  List<Object?> get props => [userId, plateNumber, type, photoPath];
}

class EditVehicleEvent extends VehicleEvent {
  final String id;
  final String? plateNumber;
  final String? type;
  final String? photoPath;

  const EditVehicleEvent({
    required this.id,
    this.plateNumber,
    this.type,
    this.photoPath,
  });

  @override
  List<Object?> get props => [id, plateNumber, type, photoPath];
}

class DeleteVehicleEvent extends VehicleEvent {
  final String vehicleId;
  const DeleteVehicleEvent(this.vehicleId);

  @override
  List<Object> get props => [vehicleId];
}
