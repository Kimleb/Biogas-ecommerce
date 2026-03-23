import 'dart:convert';
import 'dart:async';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/payment_model.dart';
import '../models/booking_model.dart';

/// M-Pesa Payment Service (Backend Integration)
/// Handles all payment operations by calling Django backend API
class MpesaService extends GetxService {
  static MpesaService get to => Get.find();

  // Django backend URL
  static const String _baseUrl =
      'https://eminently-rare-pegasus.ngrok-free.app/api';

  // Reactive state
  final RxBool isProcessingPayment = false.obs;
  final RxString paymentStatus = ''.obs;
  final Rx<PaymentModel?> currentPayment = Rx<PaymentModel?>(null);

  /// Initialize M-Pesa payment by calling Django backend
  Future<Map<String, dynamic>?> initiatePayment({
    required BookingModel booking,
    required String customerPhone,
    required String customerEmail,
    required String customerName,
    required String customerId,
  }) async {
    try {
      isProcessingPayment.value = true;
      paymentStatus.value = 'Initiating M-Pesa payment...';

      final response = await http.post(
        Uri.parse('$_baseUrl/mpesa/initiate/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'booking_id': booking.id,
          'customer_id': customerId,
          'customer_name': customerName,
          'customer_email': customerEmail,
          'customer_phone': customerPhone,
          'service_name': booking.serviceName,
          'amount': booking.totalPrice,
          'service_fee': booking.totalPrice * 0.8, // 80% service fee
          'platform_fee': booking.totalPrice * 0.2, // 20% platform fee
        }),
      );

      print('Payment Initiation Response: ${response.statusCode}');
      print('Payment Initiation Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          paymentStatus.value = 'STK Push sent successfully';

          // Create payment model for local tracking
          final payment = PaymentModel(
            id: data['payment_id'].toString(),
            bookingId: booking.id,
            userId: customerId,
            amount: booking.totalPrice,
            paymentType: PaymentType.payNow,
            status: PaymentStatus.pending,
            createdAt: DateTime.now(),
            reference: data['checkout_request_id'],
            paymentMethod: PaymentMethod.mpesa,
            verificationData: {
              'checkout_request_id': data['checkout_request_id'],
              'merchant_request_id': data['merchant_request_id'],
              'booking_id': booking.id,
              'customer_name': customerName,
              'customer_email': customerEmail,
              'service_name': booking.serviceName,
            },
          );

          currentPayment.value = payment;

          return {
            'success': true,
            'checkout_request_id': data['checkout_request_id'],
            'merchant_request_id': data['merchant_request_id'],
            'payment_id': data['payment_id'],
          };
        } else {
          paymentStatus.value = 'Payment initiation failed';
          return {'success': false, 'error': data['error']};
        }
      } else {
        String errorMessage = 'Payment initiation failed';
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['error'] ?? errorMessage;
        } catch (e) {
          errorMessage = 'HTTP ${response.statusCode}: ${response.body}';
        }

        paymentStatus.value = errorMessage;
        return {'success': false, 'error': errorMessage};
      }
    } catch (e) {
      paymentStatus.value = 'Payment initiation error: ${e.toString()}';
      print('Payment initiation error: $e');
      return {'success': false, 'error': e.toString()};
    } finally {
      isProcessingPayment.value = false;
    }
  }

  /// Check payment status by calling Django backend
  Future<Map<String, dynamic>?> checkPaymentStatus(
      String checkoutRequestId) async {
    try {
      paymentStatus.value = 'Checking payment status...';

      final response = await http.post(
        Uri.parse('$_baseUrl/mpesa/status/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'checkout_request_id': checkoutRequestId,
        }),
      );

      print('Payment Status Response: ${response.statusCode}');
      print('Payment Status Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Update local payment model if exists
        if (currentPayment.value != null &&
            currentPayment.value!.verificationData?['checkout_request_id'] ==
                checkoutRequestId) {
          final paymentData = data['payment'];
          currentPayment.value = PaymentModel(
            id: paymentData['id'].toString(),
            bookingId: paymentData['reference'] ?? '',
            userId: currentPayment.value!.userId,
            amount: double.parse(paymentData['amount'].toString()),
            paymentType: PaymentType.payNow,
            status: _parsePaymentStatus(paymentData['status']),
            createdAt: DateTime.parse(paymentData['created_at']),
            reference: paymentData['reference'] ?? '',
            paymentMethod: PaymentMethod.mpesa,
            verificationData: paymentData,
          );
        }

        paymentStatus.value = 'Payment status: ${data['status']}';

        return {
          'success': true,
          'status': data['status'],
          'payment': data['payment'],
        };
      } else {
        String errorMessage = 'Status check failed';
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['error'] ?? errorMessage;
        } catch (e) {
          errorMessage = 'HTTP ${response.statusCode}: ${response.body}';
        }

        paymentStatus.value = errorMessage;
        return {'success': false, 'error': errorMessage};
      }
    } catch (e) {
      paymentStatus.value = 'Status check error: ${e.toString()}';
      print('Payment status check error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get payment details from Django backend
  Future<Map<String, dynamic>?> getPaymentDetails(
      String checkoutRequestId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payments/$checkoutRequestId/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'payment': data};
      } else {
        return {'success': false, 'error': 'Payment not found'};
      }
    } catch (e) {
      print('Get payment details error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get booking details from Django backend
  Future<Map<String, dynamic>?> getBookingDetails(String bookingId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/bookings/$bookingId/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'booking': data};
      } else {
        return {'success': false, 'error': 'Booking not found'};
      }
    } catch (e) {
      print('Get booking details error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Check if Django backend is healthy
  Future<bool> checkBackendHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/health/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'healthy' && data['mpesa_configured'] == true;
      }
      return false;
    } catch (e) {
      print('Backend health check error: $e');
      return false;
    }
  }

  /// Parse payment status from backend
  PaymentStatus _parsePaymentStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'completed':
        return PaymentStatus.completed;
      case 'failed':
        return PaymentStatus.failed;
      default:
        return PaymentStatus.pending;
    }
  }

  /// Clear current payment
  void clearCurrentPayment() {
    currentPayment.value = null;
    paymentStatus.value = '';
    isProcessingPayment.value = false;
  }

  /// Get formatted phone number for display
  String formatPhoneNumberForDisplay(String phone) {
    if (phone.startsWith('254') && phone.length == 12) {
      return '+254 ${phone.substring(3, 6)} ${phone.substring(6, 9)} ${phone.substring(9)}';
    }
    return phone;
  }

  /// Validate phone number
  bool validatePhoneNumber(String phone) {
    // Remove all non-digit characters
    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Check if it's a valid Kenyan number
    if (cleaned.startsWith('254') && cleaned.length == 12) {
      return true;
    }
    if (cleaned.startsWith('0') && cleaned.length == 10) {
      return true;
    }
    if (cleaned.startsWith('7') && cleaned.length == 9) {
      return true;
    }

    return false;
  }
}
