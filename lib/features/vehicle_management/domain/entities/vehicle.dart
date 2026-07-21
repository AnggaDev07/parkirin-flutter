// lib/features/vehicle_management/domain/entities/vehicle.dart

import 'package:equatable/equatable.dart';

class Vehicle extends Equatable {
  final String id;
  final String userId;
  final String plateNumber;
  final String type;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Vehicle({
    required this.id,
    required this.userId,
    required this.plateNumber,
    required this.type,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        plateNumber,
        type,
        photoUrl,
        createdAt,
        updatedAt,
      ];
}
