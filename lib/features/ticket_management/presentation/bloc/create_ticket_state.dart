// lib/features/ticket_management/presentation/bloc/create_ticket_state.dart

import 'package:equatable/equatable.dart';
import 'package:parkirin/features/vehicle_management/domain/entities/vehicle.dart';

abstract class CreateTicketState extends Equatable {
  const CreateTicketState();

  @override
  List<Object?> get props => [];
}

class CreateTicketInitial extends CreateTicketState {}

class CreateTicketLoading extends CreateTicketState {
  final String message;

  const CreateTicketLoading(this.message);

  @override
  List<Object> get props => [message];
}

class PlateNumberValidated extends CreateTicketState {
  final Vehicle vehicle;
  final double estimatedPrice;

  const PlateNumberValidated({
    required this.vehicle,
    required this.estimatedPrice,
  });

  @override
  List<Object> get props => [vehicle, estimatedPrice];
}

class PlateNumberInvalid extends CreateTicketState {
  final String error;

  const PlateNumberInvalid(this.error);

  @override
  List<Object> get props => [error];
}

class PriceCalculated extends CreateTicketState {
  final double amount;

  const PriceCalculated(this.amount);

  @override
  List<Object> get props => [amount];
}

class TicketCreated extends CreateTicketState {
  final String ticketId;

  const TicketCreated(this.ticketId);

  @override
  List<Object> get props => [ticketId];
}

class CreateTicketError extends CreateTicketState {
  final String error;

  const CreateTicketError(this.error);

  @override
  List<Object> get props => [error];
}
