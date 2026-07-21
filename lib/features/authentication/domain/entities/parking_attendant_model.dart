// lib/features/authentication/domain/entities/parking_attendant_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingAttendantModel {
  final String id;
  final String nijp;
  final String name;
  final String password;
  final String? phoneNumber;
  final String? email;
  final String locationName;
  final String district;
  final String supervisorName;
  final ParkingAttendantStats stats;
  final GeoPoint coordinatePoint; // Changed to GeoPoint
  final DateTime createdAt;
  final DateTime updatedAt;

  ParkingAttendantModel({
    required this.id,
    required this.nijp,
    required this.name,
    required this.password,
    this.phoneNumber,
    this.email,
    required this.locationName,
    required this.district,
    required this.supervisorName,
    required this.stats,
    GeoPoint? coordinatePoint, // Changed parameter
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : coordinatePoint = coordinatePoint ?? const GeoPoint(0, 0),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Convenience getters for latitude and longitude
  double get latitude => coordinatePoint.latitude;
  double get longitude => coordinatePoint.longitude;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nijp': nijp,
      'name': name,
      'password': password,
      'phoneNumber': phoneNumber,
      'email': email,
      'locationName': locationName,
      'district': district,
      'supervisorName': supervisorName,
      'stats': stats.toMap(),
      'coordinatePoint': coordinatePoint, // Changed field
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ParkingAttendantModel copyWith({
    String? id,
    String? nijp,
    String? name,
    String? password,
    String? phoneNumber,
    String? email,
    String? locationName,
    String? district,
    String? supervisorName,
    ParkingAttendantStats? stats,
    GeoPoint? coordinatePoint,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ParkingAttendantModel(
      id: id ?? this.id,
      nijp: nijp ?? this.nijp,
      name: name ?? this.name,
      password: password ?? this.password,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      locationName: locationName ?? this.locationName,
      district: district ?? this.district,
      supervisorName: supervisorName ?? this.supervisorName,
      stats: stats ?? this.stats,
      coordinatePoint: coordinatePoint ?? this.coordinatePoint,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ParkingAttendantModel.fromMap(Map<String, dynamic> map) {
    return ParkingAttendantModel(
      id: map['id'],
      nijp: map['nijp'],
      name: map['name'],
      password: map['password'] ?? '',
      phoneNumber: map['phoneNumber'],
      email: map['email'],
      locationName: map['locationName'],
      district: map['district'],
      supervisorName: map['supervisorName'],
      stats: ParkingAttendantStats.fromMap(map['stats'] ?? {}),
      coordinatePoint: map['coordinatePoint'] as GeoPoint? ??
          const GeoPoint(0, 0), // Changed field
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}

class ParkingAttendantStats {
  final int totalTicketsIssued;
  final int totalTicketsPaid;
  final int pendingTickets;
  final double totalRevenue;
  final int parkingRecordsCount;

  ParkingAttendantStats({
    required this.totalTicketsIssued,
    required this.totalTicketsPaid,
    required this.pendingTickets,
    required this.totalRevenue,
    required this.parkingRecordsCount,
  });

  ParkingAttendantStats copyWith({
    int? totalTicketsIssued,
    int? totalTicketsPaid,
    int? pendingTickets,
    double? totalRevenue,
    int? parkingRecordsCount,
  }) {
    return ParkingAttendantStats(
      totalTicketsIssued: totalTicketsIssued ?? this.totalTicketsIssued,
      totalTicketsPaid: totalTicketsPaid ?? this.totalTicketsPaid,
      pendingTickets: pendingTickets ?? this.pendingTickets,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      parkingRecordsCount: parkingRecordsCount ?? this.parkingRecordsCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalTicketsIssued': totalTicketsIssued,
      'totalTicketsPaid': totalTicketsPaid,
      'pendingTickets': pendingTickets,
      'totalRevenue': totalRevenue,
      'parkingRecordsCount': parkingRecordsCount,
    };
  }

  factory ParkingAttendantStats.fromMap(Map<String, dynamic> map) {
    return ParkingAttendantStats(
      totalTicketsIssued: map['totalTicketsIssued'] ?? 0,
      totalTicketsPaid: map['totalTicketsPaid'] ?? 0,
      pendingTickets: map['pendingTickets'] ?? 0,
      totalRevenue: map['totalRevenue']?.toDouble() ?? 0.0,
      parkingRecordsCount: map['parkingRecordsCount'] ?? 0,
    );
  }
}
