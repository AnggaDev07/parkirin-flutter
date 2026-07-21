// lib/features/payment/presentation/bloc/payment_event.dart

import 'package:equatable/equatable.dart';
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class CreatePayment extends PaymentEvent {
  final String ticketId;
  final String userId;
  final double amount;
  final String itemName;

  const CreatePayment({
    required this.ticketId,
    required this.userId,
    required this.amount,
    required this.itemName,
  });

  @override
  List<Object> get props => [ticketId, userId, amount, itemName];
}

class LoadPayment extends PaymentEvent {
  final String paymentId;

  const LoadPayment(this.paymentId);

  @override
  List<Object> get props => [paymentId];
}

class RedeemFreeParking extends PaymentEvent {
  final String userId;
  final String ticketId;

  const RedeemFreeParking({
    required this.userId,
    required this.ticketId,
  });

  @override
  List<Object> get props => [userId, ticketId];
}

// New event for handling payment completion
class ProcessPaymentCompletion extends PaymentEvent {
  final String paymentId;
  final String ticketId;
  final PaymentStatus status;

  const ProcessPaymentCompletion({
    required this.paymentId,
    required this.ticketId,
    required this.status,
  });

  @override
  List<Object> get props => [paymentId, ticketId, status];
}
