// lib/features/ticket_management/presentation/bloc/ticket_bloc.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';
import 'package:parkirin/features/ticket_management/domain/repositories/i_parking_record_repository.dart';
import 'package:parkirin/features/ticket_management/domain/repositories/i_ticket_repository.dart';
import 'package:parkirin/features/ticket_management/domain/usecases/get_ticket_stream_usecase.dart';
import 'package:parkirin/features/ticket_management/domain/usecases/get_tickets_by_date_range_usecase.dart';
import 'package:parkirin/features/ticket_management/domain/usecases/get_user_tickets_count_usecase.dart';
import 'package:parkirin/features/ticket_management/domain/usecases/get_user_tickets_usecase.dart';
import 'package:parkirin/features/ticket_management/domain/usecases/search_tickets_usecase.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/ticket_event.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/ticket_state.dart';

class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final GetUserTicketsUseCase _getUserTicketsUseCase;
  final GetTicketsByDateRangeUseCase _getTicketsByDateRangeUseCase;
  final SearchTicketsUseCase _searchTicketsUseCase;
  final GetTicketStreamUseCase _getTicketStreamUseCase;
  final ITicketRepository _ticketRepository;
  final IParkingRecordRepository _parkingRecordRepository;
  final GetUserTicketsCountUseCase _getUserTicketsCountUseCase;

  TicketBloc({
    required GetUserTicketsUseCase getUserTicketsUseCase,
    required GetTicketsByDateRangeUseCase getTicketsByDateRangeUseCase,
    required SearchTicketsUseCase searchTicketsUseCase,
    required GetTicketStreamUseCase getTicketStreamUseCase,
    required GetUserTicketsCountUseCase getUserTicketsCountUseCase,
    required ITicketRepository ticketRepository,
    required IParkingRecordRepository parkingRecordRepository,
  })  : _getUserTicketsUseCase = getUserTicketsUseCase,
        _getTicketsByDateRangeUseCase = getTicketsByDateRangeUseCase,
        _getUserTicketsCountUseCase = getUserTicketsCountUseCase,
        _searchTicketsUseCase = searchTicketsUseCase,
        _getTicketStreamUseCase = getTicketStreamUseCase,
        _ticketRepository = ticketRepository,
        _parkingRecordRepository = parkingRecordRepository,
        super(TicketInitial()) {
    on<LoadUserTickets>(_onLoadUserTickets);
    on<LoadTicketsByDateRange>(_onLoadTicketsByDateRange);
    on<SearchTickets>(_onSearchTickets);
    on<LoadTicketDetail>(_onLoadTicketDetail);
    on<LoadAttendantTickets>(_onLoadAttendantTickets);
    on<LoadParkingRecords>(_onLoadParkingRecords);
    on<LoadUserTicketsCount>(_onLoadUserTicketsCount);
  }

  Future<void> _onLoadAttendantTickets(
    LoadAttendantTickets event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketLoading());
    try {
      final tickets = await _ticketRepository.getAttendantTickets(
        attendantId: event.attendantId,
        status: event.status,
        paymentType: event.paymentType,
        startDate: event.startDate,
        endDate: event.endDate,
        excludeCompleted: event.excludeCompleted,
      );
      emit(TicketsLoaded(tickets));
    } catch (e) {
      debugPrint('Error loading attendant tickets: $e');
      emit(TicketError(e.toString()));
    }
  }

  Future<void> _onLoadUserTicketsCount(
    LoadUserTicketsCount event,
    Emitter<TicketState> emit,
  ) async {
    try {
      debugPrint('Getting tickets count for user: ${event.userId}');
      emit(TicketLoading());

      final ticketCount = await _getUserTicketsCountUseCase(
        event.userId,
        status: event.status ?? TicketStatus.pending,
      );
      debugPrint('Found $ticketCount tickets with status: ${event.status}');
      emit(TicketCountLoaded(ticketCount));
    } catch (e) {
      debugPrint('Error loading tickets count: $e');
      emit(TicketError(e.toString()));
    }
  }

  Future<void> _onLoadTicketDetail(
    LoadTicketDetail event,
    Emitter<TicketState> emit,
  ) async {
    List<Ticket> currentTickets = [];

    try {
      // Keep existing tickets if available
      if (state is TicketsLoaded) {
        currentTickets = List<Ticket>.from((state as TicketsLoaded).tickets);
      }

      emit(TicketLoading());
      debugPrint('Loading ticket detail: ${event.ticketId}');

      // Get the specific ticket
      final ticketStream = _getTicketStreamUseCase(event.ticketId);
      await for (final ticket in ticketStream) {
        // If we have existing tickets, update the specific one
        if (currentTickets.isNotEmpty) {
          final updatedTickets = List<Ticket>.from(currentTickets);
          final index =
              updatedTickets.indexWhere((t) => t.id == event.ticketId);
          if (index != -1) {
            updatedTickets[index] = ticket;
          } else {
            updatedTickets.add(ticket);
          }
          emit(TicketsLoaded(updatedTickets));
        } else {
          // If no existing tickets, emit just this one
          emit(TicketsLoaded([ticket]));
        }
        break; // We only need the first emission
      }
    } catch (e) {
      debugPrint('Error loading ticket detail: $e');
      // If error occurs, maintain existing tickets in the error state
      emit(TicketError(e.toString()));
      if (currentTickets.isNotEmpty) {
        emit(TicketsLoaded(currentTickets));
      }
    }
  }

  Future<void> _onLoadUserTickets(
    LoadUserTickets event,
    Emitter<TicketState> emit,
  ) async {
    try {
      emit(TicketLoading());
      debugPrint('Loading tickets for user: ${event.userId}');

      final tickets = await _getUserTicketsUseCase(event.userId);

      debugPrint('Loaded ${tickets.length} tickets');
      emit(TicketsLoaded(tickets));
    } catch (e) {
      debugPrint('Error loading tickets: $e');
      emit(TicketError(e.toString()));
    }
  }

  Future<void> _onLoadTicketsByDateRange(
    LoadTicketsByDateRange event,
    Emitter<TicketState> emit,
  ) async {
    try {
      emit(TicketLoading());
      debugPrint(
          'Loading tickets for date range: ${event.startDate} - ${event.endDate}');

      final tickets = await _getTicketsByDateRangeUseCase(
        userId: event.userId,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      debugPrint('Loaded ${tickets.length} tickets for date range');
      emit(TicketsLoaded(tickets));
    } catch (e) {
      debugPrint('Error loading tickets by date range: $e');
      emit(TicketError(e.toString()));
    }
  }

  Future<void> _onSearchTickets(
    SearchTickets event,
    Emitter<TicketState> emit,
  ) async {
    try {
      emit(TicketLoading());
      debugPrint('Searching tickets with filters: ${event.toString()}');

      final tickets = await _searchTicketsUseCase(
        userId: event.userId,
        plateNumber: event.plateNumber,
        date: event.date,
        status: event.status,
        paymentStatus: event.paymentStatus,
      );

      debugPrint('Found ${tickets.length} tickets matching search criteria');
      emit(TicketsLoaded(tickets));
    } catch (e) {
      debugPrint('Error searching tickets: $e');
      emit(TicketError(e.toString()));
    }
  }

  // Helper method to get stream of specific ticket
  Stream<TicketState> getTicketStream(String ticketId) {
    return _getTicketStreamUseCase(ticketId)
        .map((ticket) => TicketsLoaded([ticket]))
        .handleError((error) => TicketError(error.toString()));
  }

  Future<void> _onLoadParkingRecords(
    LoadParkingRecords event,
    Emitter<TicketState> emit,
  ) async {
    try {
      emit(TicketLoading());
      final records = await _parkingRecordRepository.getAttendantRecords(
        attendantId: event.attendantId,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(ParkingRecordsLoaded(records));
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }
}
