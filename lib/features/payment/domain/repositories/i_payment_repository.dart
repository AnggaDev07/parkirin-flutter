// lib/features/payment/domain/repositories/i_payment_repository.dart

import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';

import '../entities/payment.dart';

abstract class IPaymentRepository {
  Future<Payment> createPayment({
    required String ticketId,
    required String userId,
    required double amount,
    required String itemName,
  });

  Future<Payment> getPaymentById(String paymentId);

  Future<Payment> updatePaymentStatus({
    required String paymentId,
    required PaymentStatus status,
  });

  Future<Map<String, String>> generateSnapToken({
    required String orderId,
    required int amount,
    required String itemName,
  });

  Stream<Payment> getPaymentStream(String paymentId);
}
