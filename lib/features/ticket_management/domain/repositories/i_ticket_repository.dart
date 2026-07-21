// lib/features/ticket_management/domain/repositories/i_ticket_repository.dart

import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';

abstract class ITicketRepository {
  // Driver methods
  Future<List<Ticket>> getUserTickets(String userId);
  Future<Ticket?> getTicketById(String ticketId);
  Future<int> getUserTicketsCount(String userId);
  Future<int> getUserTicketsCountByStatus(String userId, TicketStatus status);
  Future<List<Ticket>> getActiveUserTickets(String userId);
  Future<List<Ticket>> getAttendantTickets({
    required String attendantId,
    PaymentType? paymentType,
    TicketStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    bool excludeCompleted = false,
    int? limit,
  });
  Future<List<Ticket>> getUserTicketsByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  // Real-time ticket updates
  Stream<Ticket> getTicketStream(String ticketId);
  Stream<List<Ticket>> getUserTicketsStream(String userId);

  // Payment related
  Future<void> updatePaymentStatus({
    required String ticketId,
    required PaymentStatus status,
    required PaymentType type,
  });

  Future<void> editTicket({
    required String ticketId,
    String? vehiclePlateNumber,
    String? vehicleType,
    double? amount,
    PaymentType? paymentType,
  });

  // Status updates
  Future<void> updateTicketStatus({
    required String ticketId,
    required TicketStatus status,
  });

  // For attendant-initiated tickets
  Future<String> createParkingTicket({
    required String userId,
    required String attendantId,
    required String vehiclePlateNumber,
    required String vehicleType,
    required String locationName,
    required double latitude,
    required double longitude,
    required double amount,
    required PaymentType paymentType,
  });

  // Search functionality
  Future<List<Ticket>> searchTickets({
    required String userId,
    String? plateNumber,
    DateTime? date,
    TicketStatus? status,
    PaymentStatus? paymentStatus,
  });
}
