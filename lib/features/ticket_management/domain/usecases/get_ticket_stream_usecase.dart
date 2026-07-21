// lib/features/ticket_management/domain/usecases/get_ticket_stream_usecase.dart
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';
import 'package:parkirin/features/ticket_management/domain/repositories/i_ticket_repository.dart';

class GetTicketStreamUseCase {
  final ITicketRepository repository;

  GetTicketStreamUseCase(this.repository);

  Stream<Ticket> call(String ticketId) {
    return repository.getTicketStream(ticketId);
  }
}
