// lib/features/driver/presentation/bloc/latest_pending_bills_state.dart
import 'package:equatable/equatable.dart';
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';

abstract class LatestPendingBillsState extends Equatable {
  const LatestPendingBillsState();

  @override
  List<Object?> get props => [];
}

class LatestPendingBillsInitial extends LatestPendingBillsState {}

class LatestPendingBillsLoading extends LatestPendingBillsState {}

class LatestPendingBillsLoaded extends LatestPendingBillsState {
  final List<Ticket> tickets;

  const LatestPendingBillsLoaded(this.tickets);

  @override
  List<Object> get props => [tickets];
}

class LatestPendingBillsError extends LatestPendingBillsState {
  final String message;

  const LatestPendingBillsError(this.message);

  @override
  List<Object> get props => [message];
}
