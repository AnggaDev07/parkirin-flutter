// lib/features/ticket_management/presentation/bloc/record_parking_event.dart

import 'package:equatable/equatable.dart';

abstract class RecordParkingEvent extends Equatable {
  const RecordParkingEvent();

  @override
  List<Object?> get props => [];
}

class CalculatePrice extends RecordParkingEvent {
  final String vehicleType;

  const CalculatePrice(this.vehicleType);

  @override
  List<Object> get props => [vehicleType];
}

class CreateParkingRecord extends RecordParkingEvent {
  final String attendantId;
  final String plateNumber;
  final String vehicleType;
  final String locationName;
  final double latitude;
  final double longitude;
  final DateTime entryTime;
  final DateTime exitTime;

  const CreateParkingRecord({
    required this.attendantId,
    required this.plateNumber,
    required this.vehicleType,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.entryTime,
    required this.exitTime,
  });

  @override
  List<Object> get props => [
        attendantId,
        plateNumber,
        vehicleType,
        locationName,
        latitude,
        longitude,
        entryTime,
        exitTime,
      ];
}
