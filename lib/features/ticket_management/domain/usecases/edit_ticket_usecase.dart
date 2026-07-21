import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';
import 'package:parkirin/features/ticket_management/domain/repositories/i_ticket_repository.dart';

class EditTicketUseCase {
  final ITicketRepository _repository;

  EditTicketUseCase(this._repository);

  // Add price calculation logic
  double _calculatePrice(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'motorcycle':
        return 2000.0;
      case 'car':
        return 5000.0;
      case 'truck':
        return 10000.0;
      case 'bus':
        return 15000.0;
      default:
        return 5000.0;
    }
  }

  Future<void> call({
    required String ticketId,
    String? vehiclePlateNumber,
    String? vehicleType,
    double? amount,
    PaymentType? paymentType,
  }) async {
    final ticket = await _repository.getTicketById(ticketId);
    if (ticket == null) {
      throw Exception('Ticket not found');
    }

    if (!ticket.isEditable) {
      final remaining = ticket.remainingEditTime;
      throw Exception(
        'Ticket cannot be edited. Time window expired ${-remaining.inMinutes} minutes ago.',
      );
    }

    // If vehicle type changes, recalculate the price
    double? newAmount = amount;
    if (vehicleType != null && vehicleType != ticket.vehicleType) {
      newAmount = _calculatePrice(vehicleType);
    }

    return _repository.editTicket(
      ticketId: ticketId,
      vehiclePlateNumber: vehiclePlateNumber,
      vehicleType: vehicleType,
      amount: newAmount, // Use the recalculated amount
      paymentType: paymentType,
    );
  }
}
