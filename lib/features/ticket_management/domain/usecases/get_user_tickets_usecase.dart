// lib/features/ticket_management/domain/usecases/get_user_tickets_usecase.dart
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';
import 'package:parkirin/features/ticket_management/domain/repositories/i_ticket_repository.dart';

class GetUserTicketsUseCase {
  final ITicketRepository repository;

  GetUserTicketsUseCase(this.repository);

  Future<List<Ticket>> call(String userId) {
    return repository.getUserTickets(userId);
  }
}
