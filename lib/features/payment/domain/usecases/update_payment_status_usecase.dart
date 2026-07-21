// lib/features/payment/domain/usecases/update_payment_status_usecase.dart

import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';

import '../entities/payment.dart';
import '../repositories/i_payment_repository.dart';

class UpdatePaymentStatusUseCase {
  final IPaymentRepository _repository;

  UpdatePaymentStatusUseCase(this._repository);

  Future<Payment> call({
    required String paymentId,
    required PaymentStatus status,
  }) {
    return _repository.updatePaymentStatus(
      paymentId: paymentId,
      status: status,
    );
  }
}
