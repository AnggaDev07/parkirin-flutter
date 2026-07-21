// lib/features/payment/data/repositories/firebase_payment_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:parkirin/features/payment/data/services/midtrans_service.dart';
import 'package:parkirin/features/payment/domain/entities/payment.dart';
import 'package:parkirin/features/payment/domain/repositories/i_payment_repository.dart';
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';

class FirebasePaymentRepository implements IPaymentRepository {
  final FirebaseFirestore _firestore;
  final MidtransService _midtransService;
  late final CollectionReference _paymentsCollection;

  FirebasePaymentRepository({
    FirebaseFirestore? firestore,
    MidtransService? midtransService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _midtransService = midtransService ?? MidtransService() {
    _paymentsCollection = _firestore.collection('payments');
  }

  @override
  Future<Map<String, String>> generateSnapToken({
    required String orderId,
    required int amount,
    required String itemName,
  }) async {
    try {
      debugPrint('Generating snap token for order: $orderId');
      final response = await _midtransService.createTransaction(
        orderId: orderId,
        amount: amount,
        itemName: itemName,
        customerFirstName: 'Customer',
        customerEmail: 'customer@email.com',
        customerPhone: '08123456789',
      );
      debugPrint('Successfully generated snap token: ${response['token']}');
      return response;
    } catch (e) {
      debugPrint('Error generating snap token: $e');
      rethrow;
    }
  }

  @override
  Future<Payment> createPayment({
    required String ticketId,
    required String userId,
    required double amount,
    required String itemName,
  }) async {
    try {
      debugPrint('Creating payment for ticket: $ticketId');
      final docRef = _paymentsCollection.doc();
      final now = DateTime.now();

      // Generate Snap token first
      final transactionData = await generateSnapToken(
        orderId: docRef.id,
        amount: amount.toInt(),
        itemName: itemName,
      );

      debugPrint('Got transaction data: $transactionData');

      // Create payment with the generated token and URL
      final payment = Payment(
        id: docRef.id,
        ticketId: ticketId,
        userId: userId,
        amount: amount,
        status: PaymentStatus.pending,
        snapToken: transactionData['token'],
        paymentUrl: transactionData['redirect_url'],
        createdAt: now,
        updatedAt: now,
      );

      // Save to Firestore
      await docRef.set(_paymentToMap(payment));
      debugPrint('Payment created successfully: ${payment.id}');

      return payment;
    } catch (e) {
      debugPrint('Error creating payment: $e');
      rethrow;
    }
  }

  @override
  Future<Payment> getPaymentById(String paymentId) async {
    try {
      final doc = await _paymentsCollection.doc(paymentId).get();
      if (!doc.exists) throw Exception('Payment not found');
      return _documentToPayment(doc);
    } catch (e) {
      throw Exception('Failed to get payment: $e');
    }
  }

  @override
  Stream<Payment> getPaymentStream(String paymentId) {
    return _paymentsCollection.doc(paymentId).snapshots().map((doc) {
      if (!doc.exists) throw Exception('Payment not found');
      return _documentToPayment(doc);
    });
  }

  @override
  Future<Payment> updatePaymentStatus({
    required String paymentId,
    required PaymentStatus status,
  }) async {
    try {
      await _paymentsCollection.doc(paymentId).update({
        'status': status.toString(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return getPaymentById(paymentId);
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  // Helper methods to convert between Firestore documents and Payment entities
  Map<String, dynamic> _paymentToMap(Payment payment) {
    return {
      'id': payment.id,
      'ticketId': payment.ticketId,
      'userId': payment.userId,
      'amount': payment.amount,
      'status': payment.status.toString(),
      'snapToken': payment.snapToken,
      'paymentUrl': payment.paymentUrl,
      'createdAt': Timestamp.fromDate(payment.createdAt),
      'updatedAt': Timestamp.fromDate(payment.updatedAt),
    };
  }

  Payment _documentToPayment(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Payment(
      id: doc.id,
      ticketId: data['ticketId'],
      userId: data['userId'],
      amount: data['amount'].toDouble(),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
      ),
      snapToken: data['snapToken'],
      paymentUrl: data['paymentUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}
