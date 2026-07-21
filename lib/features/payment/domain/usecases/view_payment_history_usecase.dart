// lib/features/payment/domain/usecases/view_payment_history_usecase.dart

import 'package:parkirin/features/payment/domain/entities/payment.dart';

import '../../../ticket_management/domain/entities/ticket.dart';

class ViewPaymentHistoryUseCase {
  ViewPaymentHistoryUseCase();

  Future<List<Payment>> call({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    PaymentStatus? status,
  }) async {
    // First, we need to add this method to the repository interface
    // TODO: Add getPaymentHistory method to IPaymentRepository
    throw UnimplementedError('Repository method not yet implemented');

    // The implementation will look like this once the repository is updated:
    /*
    return _paymentRepository.getPaymentHistory(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
      status: status,
    );
    */
  }
}
