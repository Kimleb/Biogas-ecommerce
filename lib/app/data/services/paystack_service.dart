import 'dart:convert';
import 'dart:math';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/payment_model.dart';
import '../models/booking_model.dart';

/// Paystack Payment Service
/// Handles all payment operations with Paystack API
class PaystackService extends GetxService {
  static PaystackService get to => Get.find();

  // Paystack configuration
  static const String _baseUrl = 'https://api.paystack.co';
  static const String _secretKey =
      'YOUR_PAYSTACK_SECRET_KEY'; // Move to env vars

  // Reactive state
  final RxBool isProcessingPayment = false.obs;
  final RxString paymentStatus = ''.obs;
  final Rx<PaymentModel?> currentPayment = Rx<PaymentModel?>(null);

  /// Initialize payment for service booking
  Future<PaymentModel?> initializeServicePayment({
    required BookingModel booking,
    required String email,
    required double amount,
    required PaymentType paymentType,
    PaymentMethod paymentMethod = PaymentMethod.mpesa,
    String? phoneNumber,
  }) async {
    try {
      isProcessingPayment.value = true;
      paymentStatus.value = 'Initializing payment...';

      // Create payment record
      final payment = PaymentModel(
        id: generatePaymentId(),
        bookingId: booking.id,
        userId: booking.customerId, // Assuming booking has customerId
        technicianId: booking.technicianId,
        amount: amount,
        currency: 'KES',
        paymentType: paymentType,
        status: PaymentStatus.pending,
        createdAt: DateTime.now(),
        description: 'Payment for ${booking.serviceName}',
      );

      // Initialize Paystack transaction based on payment method
      Map<String, dynamic> response;

      if (paymentMethod == PaymentMethod.mpesa) {
        response = await _initializeMpesaPayment(
          email: email,
          amount: amount,
          reference: payment.id,
          phoneNumber: phoneNumber,
          metadata: {
            'booking_id': booking.id,
            'service_name': booking.serviceName,
            'payment_type': paymentType.toString(),
          },
        );
      } else {
        response = await _initializeTransaction(
          email: email,
          amount: (amount * 100).round(), // Paystack uses amount in cents
          reference: payment.id,
          metadata: {
            'booking_id': booking.id,
            'service_name': booking.serviceName,
            'payment_type': paymentType.toString(),
          },
        );
      }

      if (response['status'] == true) {
        // Create updated payment with Paystack data
        final updatedPayment = payment.copyWith(
          authorizationUrl: response['data']?['authorization_url'],
          accessCode: response['data']?['access_code'],
          reference: response['data']?['reference'],
        );

        currentPayment.value = updatedPayment;

        // Save payment to database
        await _savePaymentToDatabase(updatedPayment);

        paymentStatus.value = 'Payment initialized successfully';
        return updatedPayment;
      } else {
        throw PaymentException(
            'Failed to initialize payment: ${response['message']}');
      }
    } catch (e) {
      paymentStatus.value = 'Payment initialization failed';
      throw PaymentException('Payment initialization failed: ${e.toString()}');
    } finally {
      isProcessingPayment.value = false;
    }
  }

  /// Initialize Paystack transaction
  Future<Map<String, dynamic>> _initializeTransaction({
    required String email,
    required int amount,
    required String reference,
    Map<String, dynamic>? metadata,
  }) async {
    final url = Uri.parse('$_baseUrl/transaction/initialize');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_secretKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'amount': amount,
        'reference': reference,
        'callback_url':
            'https://yourapp.com/payment/callback', // Your callback URL
        'metadata': metadata ?? {},
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw PaymentException('Paystack API error: ${response.body}');
    }
  }

  /// Initialize M-Pesa payment via Paystack
  Future<Map<String, dynamic>> _initializeMpesaPayment({
    required String email,
    required double amount,
    required String reference,
    required String? phoneNumber,
    Map<String, dynamic>? metadata,
  }) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      throw PaymentException('Phone number is required for M-Pesa payments');
    }

    final url = Uri.parse('$_baseUrl/charge');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_secretKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'amount': (amount * 100).round(), // Paystack uses amount in cents
        'reference': reference,
        'currency': 'KES',
        'channel': 'mobile_money',
        'phone': phoneNumber,
        'provider': 'mpesa',
        'metadata': metadata ?? {},
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw PaymentException(
          'M-Pesa payment initialization error: ${response.body}');
    }
  }

  /// Verify payment transaction
  Future<PaymentModel?> verifyPayment(String reference) async {
    try {
      paymentStatus.value = 'Verifying payment...';

      final response = await _verifyTransaction(reference);

      if (response['status'] == true &&
          response['data']['status'] == 'success') {
        // Update payment status
        final payment = currentPayment.value;
        if (payment != null) {
          final updatedPayment = payment.copyWith(
            status: PaymentStatus.completed,
            paidAt: DateTime.now(),
            verificationData: response['data'],
          );

          // Update in database
          await _updatePaymentInDatabase(updatedPayment);

          // Update booking status
          await _updateBookingStatus(updatedPayment.bookingId);

          paymentStatus.value = 'Payment verified successfully';
          return updatedPayment;
        }
      } else {
        throw PaymentException('Payment verification failed');
      }

      return null;
    } catch (e) {
      paymentStatus.value = 'Payment verification failed';
      throw PaymentException('Payment verification failed: ${e.toString()}');
    }
  }

  /// Submit M-Pesa OTP for payment completion
  Future<PaymentModel?> submitMpesaOtp(String reference, String otp) async {
    try {
      paymentStatus.value = 'Submitting OTP...';

      final response = await _submitMpesaOtp(reference: reference, otp: otp);

      if (response['status'] == true &&
          response['data']['status'] == 'success') {
        // Update payment status
        final payment = currentPayment.value;
        if (payment != null) {
          final updatedPayment = payment.copyWith(
            status: PaymentStatus.completed,
            paidAt: DateTime.now(),
            verificationData: response['data'],
          );

          // Update in database
          await _updatePaymentInDatabase(updatedPayment);

          // Update booking status
          await _updateBookingStatus(updatedPayment.bookingId);

          paymentStatus.value = 'Payment completed successfully';
          return updatedPayment;
        }
      } else {
        throw PaymentException('OTP submission failed');
      }

      return null;
    } catch (e) {
      paymentStatus.value = 'OTP submission failed';
      throw PaymentException('OTP submission failed: ${e.toString()}');
    }
  }

  /// Verify transaction with Paystack
  Future<Map<String, dynamic>> _verifyTransaction(String reference) async {
    final url = Uri.parse('$_baseUrl/transaction/verify/$reference');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $_secretKey',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw PaymentException('Paystack verification error: ${response.body}');
    }
  }

  /// Submit M-Pesa OTP for payment completion
  Future<Map<String, dynamic>> _submitMpesaOtp({
    required String reference,
    required String otp,
  }) async {
    final url = Uri.parse('$_baseUrl/charge/submit_otp');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_secretKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'reference': reference,
        'otp': otp,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw PaymentException('M-Pesa OTP submission error: ${response.body}');
    }
  }

  /// Process refund
  Future<bool> processRefund(String paymentId, String reason) async {
    try {
      paymentStatus.value = 'Processing refund...';

      // Implement refund logic
      // This would typically involve calling Paystack's refund API

      paymentStatus.value = 'Refund processed successfully';
      return true;
    } catch (e) {
      paymentStatus.value = 'Refund failed';
      throw PaymentException('Refund failed: ${e.toString()}');
    }
  }

  /// Get payment history for user
  Future<List<PaymentModel>> getPaymentHistory(String userId) async {
    try {
      // Fetch from database
      // This would query your Firebase database for user's payments
      return [];
    } catch (e) {
      throw PaymentException(
          'Failed to fetch payment history: ${e.toString()}');
    }
  }

  /// Calculate technician earnings
  Future<double> calculateTechnicianEarnings(String technicianId,
      {DateTime? startDate, DateTime? endDate}) async {
    try {
      // Calculate earnings from completed payments
      // This would query database and apply commission logic
      return 0.0;
    } catch (e) {
      throw PaymentException('Failed to calculate earnings: ${e.toString()}');
    }
  }

  // Private helper methods

  String generatePaymentId() {
    return 'pay_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond.toString().substring(0, 8)}';
  }

  Future<void> _savePaymentToDatabase(PaymentModel payment) async {
    // Save to Firebase Realtime Database
    // Implementation depends on your database structure
  }

  Future<void> _updatePaymentInDatabase(PaymentModel payment) async {
    // Update payment record in Firebase
  }

  Future<void> _updateBookingStatus(String bookingId) async {
    // Update booking status to 'paid' or 'confirmed'
  }
}

/// Custom exception for payment errors
class PaymentException implements Exception {
  final String message;

  PaymentException(this.message);

  @override
  String toString() => message;
}
