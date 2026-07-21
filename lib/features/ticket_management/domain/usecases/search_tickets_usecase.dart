// lib/features/ticket_management/domain/usecases/search_tickets_usecase.dart

import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';
import 'package:parkirin/features/ticket_management/domain/repositories/i_ticket_repository.dart';

class SearchTicketsUseCase {
  final ITicketRepository repository;

  SearchTicketsUseCase(this.repository);

  Future<List<Ticket>> call({
    required String userId,
    String? plateNumber,
    DateTime? date,
    TicketStatus? status,
    PaymentStatus? paymentStatus,
  }) {
    return repository.searchTickets(
      userId: userId,
      plateNumber: plateNumber,
      date: date,
      status: status,
      paymentStatus: paymentStatus,
    );
  }
}
