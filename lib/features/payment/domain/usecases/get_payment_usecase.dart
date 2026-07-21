// lib/features/payment/domain/usecases/get_payment_usecase.dart

import '../entities/payment.dart';
import '../repositories/i_payment_repository.dart';

class GetPaymentUseCase {
  final IPaymentRepository _repository;

  GetPaymentUseCase(this._repository);

  Future<Payment> call(String paymentId) {
    return _repository.getPaymentById(paymentId);
  }
}
