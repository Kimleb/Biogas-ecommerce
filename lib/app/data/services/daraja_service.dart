import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import '../models/payment_model.dart';
import '../models/booking_model.dart';

/// Daraja M-Pesa Payment Service
/// Handles all payment operations with Safaricom Daraja API
class DarajaService extends GetxService {
  static DarajaService get to => Get.find();

  // Daraja configuration (Sandbox - replace with production keys)
  static const String _consumerKey = 'qpAmvhJIMKwAOJ7bWqKkXwHlAbuMgN4j';
  static const String _consumerSecret = 'cDSrSkFGTzLSenqX';
  static const String _passkey =
      'bfb279c9a6ffbdf4f8b4c3e8e3c7b3c8e3c7b3c8e3c7b3c8e3c7b3c8e3c7b3c';
  static const String _shortcode = '174379'; // Test shortcode
  static const String _baseUrl = 'https://sandbox.safaricom.co.ke';
  // Django callback URL
  static const String _callbackUrl =
      'http://127.0.0.1:8000/api/mpesa/callback/';

  // Firebase Realtime Database references
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  DatabaseReference get _paymentsRef => _database.ref().child('payments');
  DatabaseReference get _bookingsRef => _database.ref().child('bookings');

  // Reactive state
  final RxBool isProcessingPayment = false.obs;
  final RxString paymentStatus = ''.obs;
  final Rx<PaymentModel?> currentPayment = Rx<PaymentModel?>(null);

  // OAuth token cache
  String? _accessToken;
  DateTime? _tokenExpiry;

  @override
  void onInit() {
    super.onInit();
    // Initialize by getting OAuth token
    _getOAuthToken();
  }

  /// Get OAuth token from Daraja API
  Future<String> _getOAuthToken() async {
    // Check if token is still valid
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken!;
    }

    try {
      final credentials =
          base64.encode(utf8.encode('$_consumerKey:$_consumerSecret'));

      print('Getting OAuth token from: $_baseUrl/oauth/v1/generate');
      print('Using Consumer Key: $_consumerKey');

      final response = await http.get(
        Uri.parse('$_baseUrl/oauth/v1/generate?grant_type=client_credentials'),
        headers: {
          'Authorization': 'Basic $credentials',
        },
      );

      print('OAuth Response Status: ${response.statusCode}');
      print(
          'OAuth Response Body: ${response.body.isNotEmpty ? response.body : "EMPTY RESPONSE"}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw DarajaException('OAuth response is empty but status is 200');
        }

        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        _tokenExpiry = DateTime.now()
            .add(Duration(seconds: 3599)); // Token expires in 1 hour
        print('OAuth Token obtained successfully');
        return _accessToken!;
      } else {
        String errorMessage =
            'Failed to get OAuth token: ${response.statusCode}';

        if (response.body.isNotEmpty) {
          try {
            final errorData = json.decode(response.body);
            errorMessage +=
                ' - ${errorData['errorDescription'] ?? errorData['error'] ?? 'Unknown error'}';
          } catch (e) {
            errorMessage += ' - Response: ${response.body}';
          }
        } else {
          errorMessage += ' - Empty response body';
        }

        throw DarajaException(errorMessage);
      }
    } catch (e) {
      print('OAuth Token Error: $e');
      throw DarajaException('OAuth token error: ${e.toString()}');
    }
  }

  /// Initialize M-Pesa STK Push for service booking
  Future<PaymentModel?> initializeServicePayment({
    required BookingModel booking,
    required String email,
    required double amount,
    required PaymentType paymentType,
    required String phoneNumber,
  }) async {
    try {
      isProcessingPayment.value = true;
      paymentStatus.value = 'Initializing M-Pesa payment...';

      // Create payment record
      final payment = PaymentModel(
        id: _generatePaymentId(),
        bookingId: booking.id,
        userId: booking.customerId,
        technicianId: booking.technicianId,
        amount: amount,
        currency: 'KES',
        paymentType: paymentType,
        status: PaymentStatus.pending,
        createdAt: DateTime.now(),
        description: 'Payment for ${booking.serviceName}',
        paymentMethod: PaymentMethod.mpesa,
      );

      // Get OAuth token
      final token = await _getOAuthToken();

      // Initiate STK Push
      final response = await _initiateStkPush(
        token: token,
        payment: payment,
        phoneNumber: phoneNumber,
        email: email,
      );

      if (response['status'] == true) {
        // Update payment with M-Pesa response data
        final updatedPayment = payment.copyWith(
          reference: response['data']?['CheckoutRequestID'],
          verificationData: response['data'],
        );

        currentPayment.value = updatedPayment;

        // Save payment to database
        await _savePaymentToDatabase(updatedPayment);

        paymentStatus.value = 'M-Pesa STK Push sent successfully';
        return updatedPayment;
      } else {
        throw DarajaException(
            'Failed to initiate M-Pesa payment: ${response['message']}');
      }
    } catch (e) {
      paymentStatus.value = 'M-Pesa payment initialization failed';
      throw DarajaException('Payment initialization failed: ${e.toString()}');
    } finally {
      isProcessingPayment.value = false;
    }
  }

  /// Initiate M-Pesa STK Push
  Future<Map<String, dynamic>> _initiateStkPush({
    required String token,
    required PaymentModel payment,
    required String phoneNumber,
    required String email,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final password = _generateStkPushPassword(timestamp);

      final requestBody = {
        'BusinessShortCode': _shortcode,
        'Password': password,
        'Timestamp': timestamp,
        'TransactionType': 'CustomerPayBillOnline',
        'Amount': payment.amount.round(),
        'PartyA': _formatPhoneNumber(phoneNumber),
        'PartyB': _shortcode,
        'PhoneNumber': _formatPhoneNumber(phoneNumber),
        'CallBackURL': _callbackUrl,
        'AccountReference': payment.bookingId,
        'TransactionDesc': payment.description,
        'Remark': 'Biogas service payment',
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/mpesa/stkpush/v1/processrequest'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['ResponseCode'] == '0') {
          return {
            'status': true,
            'data': data,
            'message': 'STK Push initiated successfully',
          };
        } else {
          return {
            'status': false,
            'message': data['ResponseDescription'] ?? 'STK Push failed',
          };
        }
      } else {
        return {
          'status': false,
          'message': 'STK Push API error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'STK Push error: ${e.toString()}',
      };
    }
  }

  /// Generate STK Push password
  String _generateStkPushPassword(String timestamp) {
    final data = '$_shortcode$_passkey$timestamp';
    final bytes = utf8.encode(data);
    return base64.encode(sha256.convert(bytes).bytes);
  }

  /// Format phone number for M-Pesa (remove + and ensure 254 prefix)
  String _formatPhoneNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.startsWith('0')) {
      cleaned = '254${cleaned.substring(1)}';
    } else if (cleaned.startsWith('7')) {
      cleaned = '254$cleaned';
    } else if (!cleaned.startsWith('254')) {
      cleaned = '254$cleaned';
    }

    return cleaned;
  }

  /// Verify payment status (called by Django callback or manual check)
  Future<PaymentModel?> verifyPayment(String checkoutRequestId) async {
    try {
      paymentStatus.value = 'Verifying M-Pesa payment...';

      final token = await _getOAuthToken();

      final response = await http.post(
        Uri.parse('$_baseUrl/mpesa/stkpushquery/v1/query'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'BusinessShortCode': _shortcode,
          'Password': _generateStkPushPassword(
              DateTime.now().millisecondsSinceEpoch.toString()),
          'Timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'CheckoutRequestID': checkoutRequestId,
          'OriginatorConversationID': '',
          'IdentifierType': '4',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['ResponseCode'] == '0') {
          final payment = currentPayment.value;
          if (payment != null) {
            final updatedPayment = payment.copyWith(
              status: PaymentStatus.completed,
              paidAt: DateTime.now(),
              verificationData: data,
            );

            // Update in database
            await _updatePaymentInDatabase(updatedPayment);

            // Update booking status
            await _updateBookingStatus(updatedPayment.bookingId);

            paymentStatus.value = 'M-Pesa payment verified successfully';
            return updatedPayment;
          }
        }
      }

      return null;
    } catch (e) {
      paymentStatus.value = 'M-Pesa payment verification failed';
      throw DarajaException('Payment verification failed: ${e.toString()}');
    }
  }

  /// Process payment callback from Django
  Future<PaymentModel?> processCallback(
      Map<String, dynamic> callbackData) async {
    try {
      final resultCode = callbackData['ResultCode'];
      final checkoutRequestId = callbackData['CheckoutRequestID'];

      // Find payment by checkout request ID
      final payment = await _findPaymentByCheckoutId(checkoutRequestId);
      if (payment == null) {
        throw DarajaException(
            'Payment not found for checkout ID: $checkoutRequestId');
      }

      PaymentStatus newStatus;
      if (resultCode == 0) {
        newStatus = PaymentStatus.completed;
        paymentStatus.value = 'M-Pesa payment completed successfully';
      } else {
        newStatus = PaymentStatus.failed;
        paymentStatus.value = 'M-Pesa payment failed';
      }

      final updatedPayment = payment.copyWith(
        status: newStatus,
        paidAt: newStatus == PaymentStatus.completed ? DateTime.now() : null,
        verificationData: callbackData,
      );

      // Update in database
      await _updatePaymentInDatabase(updatedPayment);

      // Update booking status if payment completed
      if (newStatus == PaymentStatus.completed) {
        await _updateBookingStatus(updatedPayment.bookingId);
      }

      currentPayment.value = updatedPayment;
      return updatedPayment;
    } catch (e) {
      throw DarajaException('Callback processing failed: ${e.toString()}');
    }
  }

  /// Find payment by checkout request ID
  Future<PaymentModel?> _findPaymentByCheckoutId(String checkoutId) async {
    try {
      final snapshot = await _paymentsRef.get();
      if (snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        for (final entry in data.entries) {
          final payment =
              PaymentModel.fromJson(Map<String, dynamic>.from(entry.value));
          if (payment.reference == checkoutId) {
            return payment;
          }
        }
      }
      return null;
    } catch (e) {
      throw DarajaException('Failed to find payment: ${e.toString()}');
    }
  }

  /// Get payment history for user
  Future<List<PaymentModel>> getPaymentHistory(String userId) async {
    try {
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
      throw DarajaException('Failed to fetch payment history: ${e.toString()}');
    }
  }

  /// Generate unique payment ID
  String _generatePaymentId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(99999).toString().padLeft(5, '0');
    return 'mpesa_${timestamp}_$random';
  }

  /// Save payment to database
  Future<void> _savePaymentToDatabase(PaymentModel payment) async {
    try {
      await _paymentsRef.child(payment.id).set(payment.toJson());
    } catch (e) {
      throw DarajaException('Failed to save payment: ${e.toString()}');
    }
  }

  /// Update payment in database
  Future<void> _updatePaymentInDatabase(PaymentModel payment) async {
    try {
      await _paymentsRef.child(payment.id).update(payment.toJson());
    } catch (e) {
      throw DarajaException('Failed to update payment: ${e.toString()}');
    }
  }

  /// Update booking status
  Future<void> _updateBookingStatus(String bookingId) async {
    try {
      await _bookingsRef.child(bookingId).update({
        'status': 'paid',
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw DarajaException('Failed to update booking: ${e.toString()}');
    }
  }
}

/// Custom exception for Daraja M-Pesa errors
class DarajaException implements Exception {
  final String message;

  DarajaException(this.message);

  @override
  String toString() => message;
}
