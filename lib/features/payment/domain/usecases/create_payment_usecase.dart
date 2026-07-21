// lib/features/payment/domain/usecases/create_payment_usecase.dart

import '../entities/payment.dart';
import '../repositories/i_payment_repository.dart';

class CreatePaymentUseCase {
  final IPaymentRepository _repository;

  CreatePaymentUseCase(this._repository);

  Future<Payment> call({
    required String ticketId,
    required String userId,
    required double amount,
    required String itemName,
  }) {
    return _repository.createPayment(
      ticketId: ticketId,
      userId: userId,
      amount: amount,
      itemName: itemName,
    );
  }
}
