// lib/features/payment/data/services/payment_status_checker.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:parkirin/features/payment/domain/repositories/i_payment_repository.dart';
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';

import '../services/midtrans_service.dart';

class PaymentStatusChecker {
  final IPaymentRepository _paymentRepository;
  final MidtransService _midtransService;
  Timer? _timer;

  PaymentStatusChecker({
    required IPaymentRepository paymentRepository,
    required MidtransService midtransService,
  })  : _paymentRepository = paymentRepository,
        _midtransService = midtransService;

  void startChecking({
    required String paymentId,
    required String ticketId,
    required Function(PaymentStatus) onStatusUpdate,
    required Function() onComplete,
  }) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final payment = await _paymentRepository.getPaymentById(paymentId);
        final midtransResponse =
            await _midtransService.checkTransaction(paymentId);

        final status =
            _convertMidtransStatus(midtransResponse['transaction_status']);

        // Update payment in repository if status has changed
        if (payment.status != status) {
          await _paymentRepository.updatePaymentStatus(
            paymentId: paymentId,
            status: status,
          );
        }

        if (status == PaymentStatus.paid || status == PaymentStatus.failed) {
          timer.cancel();
          onStatusUpdate(status);
          onComplete();
        }
      } catch (e) {
        debugPrint('Error checking payment status: $e');
      }
    });
  }

  PaymentStatus _convertMidtransStatus(String? midtransStatus) {
    switch (midtransStatus) {
      case 'capture':
      case 'settlement':
        return PaymentStatus.paid;
      case 'deny':
      case 'cancel':
      case 'expire':
        return PaymentStatus.failed;
      case 'pending':
        return PaymentStatus.pending;
      default:
        return PaymentStatus.unpaid;
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}
