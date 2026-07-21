// lib/features/driver/presentation/bloc/pending_tickets_count_state.dart
import 'package:equatable/equatable.dart';

abstract class PendingTicketsCountState extends Equatable {
  const PendingTicketsCountState();

  @override
  List<Object?> get props => [];
}

class PendingTicketsCountInitial extends PendingTicketsCountState {}

class PendingTicketsCountLoading extends PendingTicketsCountState {}

class PendingTicketsCountLoaded extends PendingTicketsCountState {
  final int count;

  const PendingTicketsCountLoaded(this.count);

  @override
  List<Object> get props => [count];
}

class PendingTicketsCountError extends PendingTicketsCountState {
  final String message;

  const PendingTicketsCountError(this.message);

  @override
  List<Object> get props => [message];
}
