// lib/features/payment/presentation/bloc/payment_state.dart

import 'package:equatable/equatable.dart';

import '../../domain/entities/payment.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {
  final String message;

  const PaymentLoading(this.message);

  @override
  List<Object> get props => [message];
}

class PaymentCreated extends PaymentState {
  final Payment payment;

  const PaymentCreated(this.payment);

  @override
  List<Object> get props => [payment];
}

class PaymentLoaded extends PaymentState {
  final Payment payment;

  const PaymentLoaded(this.payment);

  @override
  List<Object> get props => [payment];
}

// Add the new PaymentCompleted state
class PaymentCompleted extends PaymentState {
  final Payment payment;

  const PaymentCompleted(this.payment);

  @override
  List<Object> get props => [payment];
}

class RedemptionCompleted extends PaymentState {
  final String ticketId;

  const RedemptionCompleted(this.ticketId);

  @override
  List<Object> get props => [ticketId];
}

class PaymentError extends PaymentState {
  final String error;

  const PaymentError(this.error);

  @override
  List<Object> get props => [error];
}
