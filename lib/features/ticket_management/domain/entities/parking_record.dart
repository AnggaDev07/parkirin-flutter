// lib/features/ticket_management/domain/entities/parking_record.dart

import 'package:equatable/equatable.dart';

enum ParkingRecordStatus {
  active, // When vehicle is currently parked
  completed, // When vehicle has left
  cancelled // When record is cancelled/voided
}

class ParkingRecord extends Equatable {
  final String id;
  final String attendantId;
  final String vehiclePlateNumber;
  final String vehicleType;
  final String locationName;
  final double latitude;
  final double longitude;
  final DateTime entryTime;
  final DateTime? exitTime;
  final double amount;
  final ParkingRecordStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ParkingRecord({
    required this.id,
    required this.attendantId,
    required this.vehiclePlateNumber,
    required this.vehicleType,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.entryTime,
    this.exitTime,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // Utility method to check if parking is completed
  bool get isCompleted => status == ParkingRecordStatus.completed;

  // Get duration of parking (current or total)
  Duration getParkingDuration() {
    return exitTime?.difference(entryTime) ??
        DateTime.now().difference(entryTime);
  }

  // Create a copy with updated fields
  ParkingRecord copyWith({
    String? id,
    String? attendantId,
    String? vehiclePlateNumber,
    String? vehicleType,
    String? locationName,
    double? latitude,
    double? longitude,
    DateTime? entryTime,
    DateTime? exitTime,
    double? amount,
    ParkingRecordStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ParkingRecord(
      id: id ?? this.id,
      attendantId: attendantId ?? this.attendantId,
      vehiclePlateNumber: vehiclePlateNumber ?? this.vehiclePlateNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      entryTime: entryTime ?? this.entryTime,
      exitTime: exitTime ?? this.exitTime,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        attendantId,
        vehiclePlateNumber,
        vehicleType,
        locationName,
        latitude,
        longitude,
        entryTime,
        exitTime,
        amount,
        status,
        createdAt,
        updatedAt,
      ];
}
