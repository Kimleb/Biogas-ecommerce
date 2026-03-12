import 'dart:convert';
import 'dart:math';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import '../models/payment_model.dart';
import '../models/booking_model.dart';
import '../../../config/paystack_config.dart';

/// Paystack Payment Service
/// Handles all payment operations with Paystack API
class PaystackService extends GetxService {
  static PaystackService get to => Get.find();

  // Paystack configuration
  static const String _publicKey =
      'pk_test_bd3d18cb55e7eee0a876a5d4d46a05940785f756'; // Replace with your public key
  static const String _secretKey =
      'sk_test_c6cf2ac689d6a1455342e00e8e077508cf2ad04f'; // Replace with your secret key

  // Firebase Realtime Database references
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  DatabaseReference get _paymentsRef => _database.ref().child('payments');

  DatabaseReference get _bookingsRef => _database.ref().child('bookings');

  // Reactive state
  final RxBool isProcessingPayment = false.obs;
  final RxString paymentStatus = ''.obs;
  final Rx<PaymentModel?> currentPayment = Rx<PaymentModel?>(null);

  // Paystack configuration
  bool _isInitialized = false;

  @override
  void onInit() {
    super.onInit();
    _isInitialized = true; // Simple initialization for REST API approach
  }

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
        currency: PaystackConfig.currency,
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

  /// Initialize Paystack transaction using REST API
  Future<Map<String, dynamic>> _initializeTransaction({
    required String email,
    required int amount,
    required String reference,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final url = Uri.parse('https://api.paystack.co/transaction/initialize');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'amount': amount,
          'reference': reference,
          'currency': PaystackConfig.currency,
          'metadata': metadata,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {
          'status': false,
          'message':
              'Transaction initialization failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': false, 'message': 'API error: ${e.toString()}'};
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

    try {
      final url = Uri.parse('https://api.paystack.co/transaction/initialize');

      // Add phone number to metadata for M-Pesa
      final updatedMetadata = <String, dynamic>{
        'phone_number': phoneNumber,
        'payment_channel': 'mpesa',
        ...?metadata,
      };

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'amount': (amount * 100).round(),
          'reference': reference,
          'currency': PaystackConfig.currency,
          'metadata': updatedMetadata,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {
          'status': false,
          'message': 'M-Pesa initialization failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': false, 'message': 'M-Pesa API error: ${e.toString()}'};
    }
  }

  /// Get payment authorization URL for web checkout
  String? getAuthorizationUrl(PaymentModel payment) {
    return payment.authorizationUrl;
  }

  /// Verify payment transaction
  Future<PaymentModel?> verifyPayment(String reference) async {
    try {
      paymentStatus.value = 'Verifying payment...';

      // Verify using Paystack REST API
      final response = await _verifyTransactionApi(reference);

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

      // Submit OTP using Paystack REST API
      final response = await _submitOtpApi(reference, otp);

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

  /// Verify transaction using Paystack REST API
  Future<Map<String, dynamic>> _verifyTransactionApi(String reference) async {
    try {
      final url =
          Uri.parse('https://api.paystack.co/transaction/verify/$reference');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {
          'status': false,
          'message': 'Verification failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'API error: ${e.toString()}',
      };
    }
  }

  /// Submit OTP using Paystack REST API
  Future<Map<String, dynamic>> _submitOtpApi(
      String reference, String otp) async {
    try {
      final url = Uri.parse('https://api.paystack.co/charge/submit_otp');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'reference': reference,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {
          'status': false,
          'message': 'OTP submission failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'API error: ${e.toString()}',
      };
    }
  }

  /// Process refund using Paystack REST API
  Future<Map<String, dynamic>> _processRefundApi(
      String transactionId, String reason) async {
    try {
      final url = Uri.parse('https://api.paystack.co/refund');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'transaction': transactionId,
          'reason': reason,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {
          'status': false,
          'message': 'Refund failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'API error: ${e.toString()}',
      };
    }
  }

  /// Process refund
  Future<bool> processRefund(String paymentId, String reason) async {
    try {
      paymentStatus.value = 'Processing refund...';

      final response = await _processRefundApi(paymentId, reason);

      if (response['status'] == true) {
        paymentStatus.value = 'Refund processed successfully';
        return true;
      } else {
        paymentStatus.value = 'Refund failed';
        return false;
      }
    } catch (e) {
      paymentStatus.value = 'Refund failed';
      throw PaymentException('Refund failed: ${e.toString()}');
    }
  }

  /// Get payment history for user
  Future<List<PaymentModel>> getPaymentHistory(String userId) async {
    try {
      // Fetch from database
      final snapshot = await _paymentsRef.orderByChild('createdAt').get();

      if (snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return data.entries
            .where((entry) => entry.value['userId'] == userId)
            .map((entry) =>
                PaymentModel.fromJson(Map<String, dynamic>.from(entry.value)))
            .toList();
      }
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
      final databaseEvent = await _paymentsRef.orderByChild('createdAt').once();
      final snapshot = databaseEvent.snapshot;

      if (snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        double totalEarnings = 0.0;

        for (final entry in data.entries) {
          final payment =
              PaymentModel.fromJson(Map<String, dynamic>.from(entry.value));
          if (payment.technicianId == technicianId &&
              payment.status == PaymentStatus.completed) {
            // Apply commission logic (e.g., 80% to technician, 20% platform)
            totalEarnings += payment.amount * 0.8;
          }
        }

        return totalEarnings;
      }
      return 0.0;
    } catch (e) {
      throw PaymentException('Failed to calculate earnings: ${e.toString()}');
    }
  }

  // Private helper methods

  String generatePaymentId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(99999).toString().padLeft(5, '0');
    return 'pay_${timestamp}_$random';
  }

  Future<void> _savePaymentToDatabase(PaymentModel payment) async {
    try {
      await _paymentsRef.child(payment.id).set(payment.toJson());
    } catch (e) {
      throw PaymentException(
          'Failed to save payment to database: ${e.toString()}');
    }
  }

  Future<void> _updatePaymentInDatabase(PaymentModel payment) async {
    try {
      await _paymentsRef.child(payment.id).update(payment.toJson());
    } catch (e) {
      throw PaymentException(
          'Failed to update payment in database: ${e.toString()}');
    }
  }

  Future<void> _updateBookingStatus(String bookingId) async {
    try {
      await _bookingsRef.child(bookingId).update({
        'status': 'paid',
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw PaymentException(
          'Failed to update booking status: ${e.toString()}');
    }
  }
}

/// Custom exception for payment errors
class PaymentException implements Exception {
  final String message;

  PaymentException(this.message);

  @override
  String toString() => message;
}
