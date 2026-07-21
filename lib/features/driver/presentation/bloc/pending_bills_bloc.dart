// lib/features/driver/presentation/bloc/pending_bills_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkirin/features/driver/presentation/bloc/pending_bills_event.dart';
import 'package:parkirin/features/driver/presentation/bloc/pending_bills_state.dart';
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';
import 'package:parkirin/features/ticket_management/domain/repositories/i_ticket_repository.dart';

class PendingBillsBloc extends Bloc<PendingBillsEvent, PendingBillsState> {
  final ITicketRepository _ticketRepository;

  PendingBillsBloc({
    required ITicketRepository ticketRepository,
  })  : _ticketRepository = ticketRepository,
        super(PendingBillsInitial()) {
    on<LoadPendingBills>(_onLoadPendingBills);
    on<RefreshPendingBills>(_onRefreshPendingBills);
  }

  Future<void> _onLoadPendingBills(
    LoadPendingBills event,
    Emitter<PendingBillsState> emit,
  ) async {
    try {
      emit(PendingBillsLoading());

      final tickets = await _ticketRepository.searchTickets(
        userId: event.userId,
        status: TicketStatus.pending,
      );

      // Sort by date descending
      tickets.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      emit(PendingBillsLoaded(tickets));
    } catch (e) {
      emit(PendingBillsError(e.toString()));
    }
  }

  Future<void> _onRefreshPendingBills(
    RefreshPendingBills event,
    Emitter<PendingBillsState> emit,
  ) async {
    try {
      final tickets = await _ticketRepository.searchTickets(
        userId: event.userId,
        status: TicketStatus.pending,
      );

      tickets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(PendingBillsLoaded(tickets));
    } catch (e) {
      emit(PendingBillsError(e.toString()));
    }
  }
}
