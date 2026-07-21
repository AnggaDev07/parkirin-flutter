// lib/features/ticket_management/presentation/bloc/create_ticket_event.dart

import 'package:equatable/equatable.dart';
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';

abstract class CreateTicketEvent extends Equatable {
  const CreateTicketEvent();

  @override
  List<Object?> get props => [];
}

class ValidatePlateNumber extends CreateTicketEvent {
  final String plateNumber;

  const ValidatePlateNumber(this.plateNumber);

  @override
  List<Object> get props => [plateNumber];
}

class CreateNewTicket extends CreateTicketEvent {
  final String attendantId;
  final String plateNumber;
  final String vehicleType;
  final String locationName;
  final double latitude;
  final double longitude;
  final PaymentType paymentType;

  const CreateNewTicket({
    required this.attendantId,
    required this.plateNumber,
    required this.vehicleType,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.paymentType,
  });

  @override
  List<Object> get props => [
        attendantId,
        plateNumber,
        vehicleType,
        locationName,
        latitude,
        longitude,
        paymentType,
      ];
}

class CalculatePrice extends CreateTicketEvent {
  final String vehicleType;

  const CalculatePrice(this.vehicleType);

  @override
  List<Object> get props => [vehicleType];
}
