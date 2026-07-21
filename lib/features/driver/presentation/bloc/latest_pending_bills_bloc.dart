// lib/features/driver/presentation/bloc/latest_pending_bills_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkirin/features/driver/presentation/bloc/latest_pending_bills_event.dart';
import 'package:parkirin/features/driver/presentation/bloc/latest_pending_bills_state.dart';
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';
import 'package:parkirin/features/ticket_management/domain/repositories/i_ticket_repository.dart';

class LatestPendingBillsBloc
    extends Bloc<LatestPendingBillsEvent, LatestPendingBillsState> {
  final ITicketRepository _ticketRepository;

  LatestPendingBillsBloc({
    required ITicketRepository ticketRepository,
  })  : _ticketRepository = ticketRepository,
        super(LatestPendingBillsInitial()) {
    on<LoadLatestPendingBills>(_onLoadLatestPendingBills);
  }

  Future<void> _onLoadLatestPendingBills(
    LoadLatestPendingBills event,
    Emitter<LatestPendingBillsState> emit,
  ) async {
    try {
      emit(LatestPendingBillsLoading());

      final tickets = await _ticketRepository.searchTickets(
        userId: event.userId,
        status: TicketStatus.pending,
      );

      // Sort by date descending
      tickets.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      emit(LatestPendingBillsLoaded(tickets));
    } catch (e) {
      emit(LatestPendingBillsError(e.toString()));
    }
  }
}
