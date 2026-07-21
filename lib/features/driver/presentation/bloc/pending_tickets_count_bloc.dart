// lib/features/driver/presentation/bloc/pending_tickets_count_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkirin/features/driver/presentation/bloc/pending_tickets_count_event.dart';
import 'package:parkirin/features/driver/presentation/bloc/pending_tickets_count_state.dart';
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';
import 'package:parkirin/features/ticket_management/domain/repositories/i_ticket_repository.dart';

class PendingTicketsCountBloc
    extends Bloc<PendingTicketsCountEvent, PendingTicketsCountState> {
  final ITicketRepository _ticketRepository;

  PendingTicketsCountBloc({
    required ITicketRepository ticketRepository,
  })  : _ticketRepository = ticketRepository,
        super(PendingTicketsCountInitial()) {
    on<LoadPendingTicketsCount>(_onLoadPendingTicketsCount);
  }

  Future<void> _onLoadPendingTicketsCount(
    LoadPendingTicketsCount event,
    Emitter<PendingTicketsCountState> emit,
  ) async {
    try {
      emit(PendingTicketsCountLoading());

      final tickets = await _ticketRepository.searchTickets(
        userId: event.userId,
        status: TicketStatus.pending,
      );

      emit(PendingTicketsCountLoaded(tickets.length));
    } catch (e) {
      emit(PendingTicketsCountError(e.toString()));
    }
  }
}
