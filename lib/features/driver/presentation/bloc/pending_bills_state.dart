// lib/features/driver/presentation/bloc/pending_bills_state.dart
import 'package:equatable/equatable.dart';
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';

abstract class PendingBillsState extends Equatable {
  const PendingBillsState();

  @override
  List<Object?> get props => [];
}

class PendingBillsInitial extends PendingBillsState {}

class PendingBillsLoading extends PendingBillsState {}

class PendingBillsLoaded extends PendingBillsState {
  final List<Ticket> tickets;

  const PendingBillsLoaded(this.tickets);

  @override
  List<Object> get props => [tickets];
}

class PendingBillsError extends PendingBillsState {
  final String message;

  const PendingBillsError(this.message);

  @override
  List<Object> get props => [message];
}
