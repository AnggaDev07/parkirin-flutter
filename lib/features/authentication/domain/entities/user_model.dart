// lib/features/authentication/domain/entities/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:parkirin/core/enums/user_role.dart';

// lib/features/authentication/domain/entities/user_model.dart

class UserModel {
  final String id;
  final String phoneNumber;
  final String? email;
  final String? name;
  final UserRole role;
  final int points;
  final List<VehicleInfo> vehicles;
  final int totalBills;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int freeParkingChances;
  final bool shouldShowCelebration;
  final int? lastPointsUpdate;

  UserModel({
    required this.id,
    required this.phoneNumber,
    this.email,
    this.name,
    required this.role,
    this.points = 0,
    this.freeParkingChances = 0,
    this.vehicles = const [],
    this.totalBills = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.shouldShowCelebration = false,
    this.lastPointsUpdate,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'email': email,
      'name': name,
      'role': role.toString(),
      'points': points,
      'vehicles': vehicles.map((v) => v.toMap()).toList(),
      'totalBills': totalBills,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'freeParkingChances': freeParkingChances,
    };
  }

  UserModel copyWith({
    String? id,
    String? phoneNumber,
    String? email,
    String? name,
    UserRole? role,
    int? points,
    List<VehicleInfo>? vehicles,
    int? totalBills,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? freeParkingChances,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      points: points ?? this.points,
      vehicles: vehicles ?? this.vehicles,
      totalBills: totalBills ?? this.totalBills,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      freeParkingChances: freeParkingChances ?? this.freeParkingChances,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, phoneNumber: $phoneNumber, email: $email, name: $name, role: $role, points: $points, vehicles: $vehicles, totalBills: $totalBills, freeParkingChances: $freeParkingChances)';
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    try {
      final createdAtValue = map['createdAt'];
      final updatedAtValue = map['updatedAt'];

      DateTime getDateTime(dynamic value) {
        if (value is Timestamp) {
          return value.toDate();
        } else if (value == null) {
          return DateTime.now();
        }
        throw Exception('Invalid timestamp format');
      }

      return UserModel(
        id: map['id'],
        phoneNumber: map['phoneNumber'],
        email: map['email'],
        name: map['name'],
        role: map['role'] == 'UserRole.driver'
            ? UserRole.driver
            : UserRole.parkingAttendant,
        points: map['points'] ?? 0,
        vehicles: (map['vehicles'] as List<dynamic>?)
                ?.map((v) => VehicleInfo.fromMap(v as Map<String, dynamic>))
                .toList() ??
            [],
        totalBills: map['totalBills'] ?? 0,
        createdAt: getDateTime(createdAtValue),
        updatedAt: getDateTime(updatedAtValue),
        freeParkingChances: map['freeParkingChances'] ?? 0,
        shouldShowCelebration: map['shouldShowCelebration'] ?? false,
        lastPointsUpdate: map['lastPointsUpdate'] as int?,
      );
    } catch (e, stackTrace) {
      debugPrint('[UserModel] Error creating from map: $e');
      debugPrint('[UserModel] Stack trace: $stackTrace');
      rethrow;
    }
  }
}

class VehicleInfo {
  final String plateNumber;
  final String type;
  final String? photoUrl;

  VehicleInfo({
    required this.plateNumber,
    required this.type,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'plateNumber': plateNumber,
      'type': type,
      'photoUrl': photoUrl,
    };
  }

  factory VehicleInfo.fromMap(Map<String, dynamic> map) {
    return VehicleInfo(
      plateNumber: map['plateNumber'],
      type: map['type'],
      photoUrl: map['photoUrl'],
    );
  }
}
