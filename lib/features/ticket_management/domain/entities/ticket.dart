// lib/features/ticket_management/domain/entities/ticket.dart

import 'package:equatable/equatable.dart';

enum TicketStatus {
  pending,
  active,
  completed,
  cancelled,
}

enum PaymentStatus {
  unpaid,
  pending, // Payment in process
  paid,
  failed,
}

enum PaymentType {
  cash,
  cashless,
}

class Ticket extends Equatable {
  final String id;
  final String userId; // Driver's ID
  final String attendantId; // Parking attendant's ID
  final String vehiclePlateNumber;
  final String vehicleType;
  final String locationName; // Parking location name
  final double latitude; // Location coordinates
  final double longitude;
  final DateTime entryTime;
  final DateTime? exitTime;
  final double amount;
  final TicketStatus status;
  final PaymentStatus paymentStatus;
  final PaymentType paymentType;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Ticket({
    required this.id,
    required this.userId,
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
    required this.paymentStatus,
    required this.paymentType,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
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
        paymentStatus,
        paymentType,
        createdAt,
        updatedAt,
      ];

  // Utility method to check if ticket is currently active
  bool get isActive => status == TicketStatus.active;

  // Utility method to check if payment is completed
  bool get isPaid => paymentStatus == PaymentStatus.paid;

  bool get isEditable {
    // Check if ticket was created within last 10 minutes
    final tenMinutesAgo = DateTime.now().subtract(const Duration(minutes: 10));
    return createdAt.isAfter(tenMinutesAgo) &&
        status != TicketStatus.cancelled &&
        status != TicketStatus.completed;
  }

  Duration get remainingEditTime {
    final deadline = createdAt.add(const Duration(minutes: 10));
    return deadline.difference(DateTime.now());
  }

  // Get duration of parking (current or total)
  Duration getParkingDuration() {
    return exitTime?.difference(entryTime) ??
        DateTime.now().difference(entryTime);
  }

  // Create a copy with updated fields
  Ticket copyWith({
    String? id,
    String? userId,
    String? attendantId,
    String? vehiclePlateNumber,
    String? vehicleType,
    String? locationName,
    double? latitude,
    double? longitude,
    DateTime? entryTime,
    DateTime? exitTime,
    double? amount,
    TicketStatus? status,
    PaymentStatus? paymentStatus,
    PaymentType? paymentType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Ticket(
      id: id ?? this.id,
      userId: userId ?? this.userId,
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
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentType: paymentType ?? this.paymentType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
