/// Paystack Configuration
/// Contains Paystack API keys and configuration settings
class PaystackConfig {
  // Test keys (replace with your actual Paystack test keys)
  static const String publicKey =
      'pk_test_bd3d18cb55e7eee0a876a5d4d46a05940785f756';
  static const String secretKey =
      'sk_test_c6cf2ac689d6a1455342e00e8e077508cf2ad04f';

  // Production keys (uncomment and replace with actual production keys)
  // static const String publicKey = 'pk_live_your_public_key_here';
  // static const String secretKey = 'sk_live_your_secret_key_here';

  // Payment settings
  static const String currency = 'KES'; // Kenyan Shilling
  static const double platformFeePercentage = 0.05; // 5% platform fee
  static const double technicianCommissionPercentage = 0.8; // 80% to technician

  // Callback URLs
  static const String successCallbackUrl =
      'https://yourapp.com/payment/success';
  static const String failureCallbackUrl =
      'https://yourapp.com/payment/failure';

  // Payment methods supported
  static const List<String> supportedPaymentMethods = [
    'mpesa',
    'card',
  ];

  // M-Pesa settings
  static const String mpesaProvider = 'mpesa';
  static const String mpesaChannel = 'mobile_money';

  // Transaction limits
  static const double minAmount = 100.0; // Minimum amount in KES
  static const double maxAmount = 100000.0; // Maximum amount in KES

  // Timeout settings
  static const Duration paymentTimeout = Duration(minutes: 15);
  static const Duration otpTimeout = Duration(minutes: 5);
}
