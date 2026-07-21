// lib/features/ticket_management/presentation/bloc/edit_ticket_state.dart

import 'package:equatable/equatable.dart';
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';
import 'package:parkirin/features/vehicle_management/domain/entities/vehicle.dart';

abstract class EditTicketState extends Equatable {
  const EditTicketState();

  @override
  List<Object?> get props => [];
}

class EditTicketInitial extends EditTicketState {}

class EditTicketLoading extends EditTicketState {
  final String message;

  const EditTicketLoading(this.message);

  @override
  List<Object> get props => [message];
}

class EditTimeValid extends EditTicketState {
  final Duration remainingTime;
  final Ticket ticket;

  const EditTimeValid({
    required this.remainingTime,
    required this.ticket,
  });

  @override
  List<Object> get props => [remainingTime, ticket];
}

class EditTimeExpired extends EditTicketState {
  final Duration expiredBy;

  const EditTimeExpired(this.expiredBy);

  @override
  List<Object> get props => [expiredBy];
}

class PlateNumberValidated extends EditTicketState {
  final Vehicle vehicle;

  const PlateNumberValidated({
    required this.vehicle,
  });

  @override
  List<Object> get props => [vehicle];
}

class PlateNumberInvalid extends EditTicketState {
  final String error;

  const PlateNumberInvalid(this.error);

  @override
  List<Object> get props => [error];
}

class EditTicketSuccess extends EditTicketState {
  final Ticket ticket;

  const EditTicketSuccess(this.ticket);

  @override
  List<Object> get props => [ticket];
}

class EditTicketError extends EditTicketState {
  final String error;

  const EditTicketError(this.error);

  @override
  List<Object> get props => [error];
}
