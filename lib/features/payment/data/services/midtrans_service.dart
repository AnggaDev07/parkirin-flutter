// lib/features/payment/data/services/midtrans_service.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:parkirin/config/midtrans_config.dart';

class MidtransService {
  final String _serverKey;
  final String _clientKey;
  final bool _isProduction;

  MidtransService({
    String? serverKey,
    String? clientKey,
    bool isProduction = false,
  })  : _serverKey = serverKey ?? MidtransConfig.serverKey,
        _clientKey = clientKey ?? MidtransConfig.clientKey,
        _isProduction = isProduction;

  String get _snapBaseUrl => _isProduction
      ? 'https://app.midtrans.com'
      : 'https://app.sandbox.midtrans.com';

  String get _apiBaseUrl => _isProduction
      ? 'https://api.midtrans.com'
      : 'https://api.sandbox.midtrans.com';

  String get clientKey => _clientKey;

  Future<Map<String, dynamic>> checkTransaction(String orderId) async {
    try {
      final auth = base64Encode(utf8.encode('$_serverKey:'));

      final response = await http.get(
        Uri.parse(
            '$_apiBaseUrl/v2/$orderId/status'), // Changed endpoint structure
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Basic $auth',
        },
      );

      debugPrint(
          'Transaction status check URL: $_apiBaseUrl/v2/$orderId/status');
      debugPrint('Transaction status response code: ${response.statusCode}');
      debugPrint('Transaction status response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to check transaction: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error checking transaction: $e');
      rethrow;
    }
  }

  Future<Map<String, String>> createTransaction({
    required String orderId,
    required int amount,
    required String itemName,
    required String customerFirstName,
    required String customerEmail,
    required String customerPhone,
  }) async {
    try {
      final auth = base64Encode(utf8.encode('$_serverKey:'));

      final response = await http.post(
        Uri.parse('$_snapBaseUrl/snap/v1/transactions'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Basic $auth',
        },
        body: jsonEncode({
          'transaction_details': {
            'order_id': orderId,
            'gross_amount': amount,
          },
          'item_details': [
            {
              'id': orderId,
              'price': amount,
              'quantity': 1,
              'name': itemName,
            }
          ],
          'customer_details': {
            'first_name': customerFirstName,
            'email': customerEmail,
            'phone': customerPhone,
          },
          'enabled_payments': ['gopay', 'bank_transfer', 'credit_card'],
          'credit_card': {'secure': true},
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'token': data['token'] as String,
          'redirect_url': data['redirect_url'] as String,
        };
      } else {
        throw Exception('Failed to create transaction: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in createTransaction: $e');
      rethrow;
    }
  }
}
