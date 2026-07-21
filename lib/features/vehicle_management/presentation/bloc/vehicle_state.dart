// lib/features/vehicle_management/presentation/bloc/vehicle_state.dart

import 'package:equatable/equatable.dart';

import '../../domain/entities/vehicle.dart';

abstract class VehicleState extends Equatable {
  const VehicleState();

  @override
  List<Object?> get props => [];
}

class VehicleInitial extends VehicleState {}

class VehicleLoading extends VehicleState {}

class VehiclesLoaded extends VehicleState {
  final List<Vehicle> vehicles;
  const VehiclesLoaded(this.vehicles);

  @override
  List<Object> get props => [vehicles];
}

class VehicleError extends VehicleState {
  final String message;
  const VehicleError(this.message);

  @override
  List<Object> get props => [message];
}

class VehicleAdded extends VehicleState {
  final Vehicle vehicle;
  const VehicleAdded(this.vehicle);

  @override
  List<Object> get props => [vehicle];
}

class VehicleDeleted extends VehicleState {
  final String vehicleId;
  const VehicleDeleted(this.vehicleId);

  @override
  List<Object> get props => [vehicleId];
}
