// lib/features/payment/domain/usecases/process_payment_usecase.dart

import 'package:parkirin/features/payment/domain/entities/payment.dart';
import 'package:parkirin/features/payment/domain/repositories/i_payment_repository.dart';
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';
import 'package:parkirin/features/ticket_management/domain/repositories/i_ticket_repository.dart';

class ProcessPaymentUseCase {
  final IPaymentRepository _paymentRepository;
  final ITicketRepository _ticketRepository;

  ProcessPaymentUseCase(this._paymentRepository, this._ticketRepository);

  Future<Payment> call({
    required String paymentId,
    required String ticketId,
    required PaymentStatus paymentStatus,
  }) async {
    // Update payment status
    final payment = await _paymentRepository.updatePaymentStatus(
      paymentId: paymentId,
      status: paymentStatus,
    );

    // If payment is successful, update ticket status
    if (paymentStatus == PaymentStatus.paid) {
      await _ticketRepository.updateTicketStatus(
        ticketId: ticketId,
        status: TicketStatus.completed,
      );

      await _ticketRepository.updatePaymentStatus(
        ticketId: ticketId,
        status: paymentStatus,
        type: PaymentType.cashless,
      );
    } else if (paymentStatus == PaymentStatus.failed) {
      await _ticketRepository.updatePaymentStatus(
        ticketId: ticketId,
        status: paymentStatus,
        type: PaymentType.cashless,
      );
    }

    return payment;
  }
}
