// lib/features/payment/domain/entities/payment.dart
import 'package:equatable/equatable.dart';
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart'; // Add this import

class Payment extends Equatable {
  final String id;
  final String ticketId;
  final String userId;
  final double amount;
  final PaymentStatus status;
  final String? snapToken;
  final String? paymentUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Payment({
    required this.id,
    required this.ticketId,
    required this.userId,
    required this.amount,
    required this.status,
    this.snapToken,
    this.paymentUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        ticketId,
        userId,
        amount,
        status,
        snapToken,
        paymentUrl,
        createdAt,
        updatedAt,
      ];
}
