// lib/features/payment/domain/usecases/redeem_free_parking_usecase.dart

import 'package:parkirin/features/authentication/data/repositories/user_repository.dart';
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';
import 'package:parkirin/features/ticket_management/domain/repositories/i_ticket_repository.dart';

class RedeemFreeParkingUseCase {
  final ITicketRepository _ticketRepository;
  final UserRepository _userRepository;

  RedeemFreeParkingUseCase(this._ticketRepository, this._userRepository);

  Future<void> call({
    required String userId,
    required String ticketId,
  }) async {
    // Deduct free parking chance
    await _userRepository.useFreeParkingChance(userId);

    // Update ticket status
    await _ticketRepository.updateTicketStatus(
      ticketId: ticketId,
      status: TicketStatus.completed,
    );

    // Update payment status
    await _ticketRepository.updatePaymentStatus(
      ticketId: ticketId,
      status: PaymentStatus.paid,
      type: PaymentType.cashless,
    );
  }
}
