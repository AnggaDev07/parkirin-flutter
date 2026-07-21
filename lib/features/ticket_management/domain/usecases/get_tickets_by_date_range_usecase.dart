// lib/features/ticket_management/domain/usecases/get_tickets_by_date_range_usecase.dart
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';
import 'package:parkirin/features/ticket_management/domain/repositories/i_ticket_repository.dart';

class GetTicketsByDateRangeUseCase {
  final ITicketRepository repository;

  GetTicketsByDateRangeUseCase(this.repository);

  Future<List<Ticket>> call({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return repository.getUserTicketsByDateRange(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
