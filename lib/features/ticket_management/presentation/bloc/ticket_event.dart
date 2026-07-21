// lib/features/ticket_management/presentation/bloc/ticket_event.dart

import 'package:equatable/equatable.dart';
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';

abstract class TicketEvent extends Equatable {
  const TicketEvent();

  @override
  List<Object?> get props => [];
}

class UpdateTicketPaymentStatus extends TicketEvent {
  final String ticketId;
  final PaymentStatus paymentStatus;

  const UpdateTicketPaymentStatus({
    required this.ticketId,
    required this.paymentStatus,
  });

  @override
  List<Object> get props => [ticketId, paymentStatus];
}

class LoadUserTickets extends TicketEvent {
  final String userId;

  const LoadUserTickets(this.userId);

  @override
  List<Object> get props => [userId];
}

class LoadTicketsByDateRange extends TicketEvent {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadTicketsByDateRange({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [userId, startDate, endDate];
}

class LoadTicketDetail extends TicketEvent {
  final String ticketId;

  const LoadTicketDetail(this.ticketId);

  @override
  List<Object> get props => [ticketId];
}

class LoadParkingRecords extends TicketEvent {
  final String attendantId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadParkingRecords({
    required this.attendantId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [attendantId, startDate, endDate];
}

class LoadAttendantTickets extends TicketEvent {
  final String attendantId;
  final TicketStatus? status;
  final PaymentType? paymentType;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool excludeCompleted;

  const LoadAttendantTickets({
    required this.attendantId,
    this.status,
    this.paymentType,
    this.startDate,
    this.endDate,
    this.excludeCompleted = false,
  });

  @override
  List<Object?> get props => [
        attendantId,
        status,
        paymentType,
        startDate,
        endDate,
        excludeCompleted,
      ];
}

class SearchTickets extends TicketEvent {
  final String userId;
  final String? plateNumber;
  final DateTime? date;
  final TicketStatus? status;
  final PaymentStatus? paymentStatus;

  const SearchTickets({
    required this.userId,
    this.plateNumber,
    this.date,
    this.status,
    this.paymentStatus,
  });

  @override
  List<Object?> get props => [
        userId,
        plateNumber,
        date,
        status,
        paymentStatus,
      ];
}

class LoadUserTicketsCount extends TicketEvent {
  final String userId;
  final TicketStatus? status;

  const LoadUserTicketsCount(this.userId, {this.status});

  @override
  List<Object?> get props => [userId, status];
}
