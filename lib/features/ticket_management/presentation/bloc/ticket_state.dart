// lib/features/ticket_management/presentation/bloc/ticket_state.dart

import 'package:equatable/equatable.dart';
import 'package:parkirin/features/ticket_management/domain/entities/parking_record.dart';
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';

abstract class TicketState extends Equatable {
  const TicketState();

  @override
  List<Object?> get props => [];
}

class TicketInitial extends TicketState {}

class TicketLoading extends TicketState {}

class TicketsLoaded extends TicketState {
  final List<Ticket> tickets;

  const TicketsLoaded(this.tickets);

  @override
  List<Object> get props => [tickets];
}

class TicketError extends TicketState {
  final String message;

  const TicketError(this.message);

  @override
  List<Object> get props => [message];
}

class ParkingRecordsLoaded extends TicketState {
  final List<ParkingRecord> records;

  const ParkingRecordsLoaded(this.records);

  @override
  List<Object> get props => [records];
}

class TicketCountLoaded extends TicketState {
  final int count;

  const TicketCountLoaded(this.count);

  @override
  List<Object> get props => [count];
}
