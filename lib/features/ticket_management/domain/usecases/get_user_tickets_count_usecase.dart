// lib/features/ticket_management/domain/usecases/get_user_tickets_count_usecase.dart

import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';
import 'package:parkirin/features/ticket_management/domain/repositories/i_ticket_repository.dart';

class GetUserTicketsCountUseCase {
  final ITicketRepository repository;

  GetUserTicketsCountUseCase(this.repository);

  Future<int> call(String userId, {TicketStatus? status}) {
    if (status != null) {
      return repository.getUserTicketsCountByStatus(userId, status);
    }
    return repository.getUserTicketsCount(userId);
  }
}
