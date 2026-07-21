// lib/features/driver/presentation/bloc/pending_tickets_count_event.dart
import 'package:equatable/equatable.dart';

abstract class PendingTicketsCountEvent extends Equatable {
  const PendingTicketsCountEvent();

  @override
  List<Object?> get props => [];
}

class LoadPendingTicketsCount extends PendingTicketsCountEvent {
  final String userId;

  const LoadPendingTicketsCount(this.userId);

  @override
  List<Object> get props => [userId];
}
