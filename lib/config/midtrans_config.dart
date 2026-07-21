// lib/config/midtrans_config.dart

class MidtransConfig {
  static const String merchantId = 'G929505097';
  static const String clientKey = 'SB-Mid-client-LeAx25F5wlkzinnO';
  static const String serverKey = 'SB-Mid-server-gXE6VW6UD48TgZ7iX1sQxTxo';

  // Change this to false for production
  static const bool isProduction = false;

  static String get baseUrl => isProduction
      ? 'https://app.midtrans.com'
      : 'https://app.sandbox.midtrans.com';

  static String get snapUrl => isProduction
      ? 'https://app.midtrans.com/snap/v1'
      : 'https://app.sandbox.midtrans.com/snap/v1';
}
