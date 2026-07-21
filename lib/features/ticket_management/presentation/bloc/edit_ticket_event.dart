// lib/features/ticket_management/presentation/bloc/edit_ticket_event.dart

import 'package:equatable/equatable.dart';
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';

abstract class EditTicketEvent extends Equatable {
  const EditTicketEvent();

  @override
  List<Object?> get props => [];
}

class ValidateEditTime extends EditTicketEvent {
  final String ticketId;

  const ValidateEditTime(this.ticketId);

  @override
  List<Object> get props => [ticketId];
}

class ValidatePlateNumber extends EditTicketEvent {
  final String plateNumber;

  const ValidatePlateNumber(this.plateNumber);

  @override
  List<Object> get props => [plateNumber];
}

class EditExistingTicket extends EditTicketEvent {
  final String ticketId;
  final String? vehiclePlateNumber;
  final String? vehicleType;
  final PaymentType? paymentType;

  const EditExistingTicket({
    required this.ticketId,
    this.vehiclePlateNumber,
    this.vehicleType,
    this.paymentType,
  });

  @override
  List<Object?> get props => [
        ticketId,
        vehiclePlateNumber,
        vehicleType,
        paymentType,
      ];
}
