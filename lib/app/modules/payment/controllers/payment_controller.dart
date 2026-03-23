import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../../data/models/booking_model.dart';
import '../../../data/models/payment_model.dart';
import '../../../data/services/mpesa_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class PaymentController extends GetxController {
  final isLightTheme = true.obs;
  final isLoading = false.obs;
  final loadingMessage = ''.obs;
  final isProcessing = false.obs;
  final selectedPaymentMethod = PaymentMethod.mpesa.obs;
  final phoneController = TextEditingController();

  /// Booking associated with this payment.
  /// Expected to be passed via Get.arguments from the booking flow.
  late final BookingModel booking;

  // Payment amounts
  double get serviceFee => booking.totalPrice;

  /// Simple platform fee (e.g. 5% of service fee).
  double get platformFee => (serviceFee * 0.05).roundToDouble();

  double get totalAmount => serviceFee + platformFee;

  /// Get user email from AuthService
  String get userEmail {
    try {
      final user = AuthService.to.currentUser;
      return user?.email ?? 'customer@example.com';
    } catch (e) {
      return 'customer@example.com';
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize booking from navigation arguments or fallback sample
    final arg = Get.arguments;
    if (arg is BookingModel) {
      booking = arg;
    } else {
      booking = BookingModel(
        id: 'booking_sample',
        customerId: 'customer_sample',
        customerName: 'Sample Customer',
        serviceId: 'service_sample',
        serviceName: 'Biogas Service',
        technicianId: null,
        bookingDate: DateTime.now(),
        serviceDate: DateTime.now().add(const Duration(days: 1)),
        status: 'pending',
        totalPrice: 2500.0,
        address: 'No address provided',
        selectedParts: const [],
      );
    }

    // Pre-fill phone number if available from user profile (static for now)
    phoneController.text = '+254712345678';
  }

  void selectPaymentMethod(PaymentMethod method) {
    selectedPaymentMethod.value = method;
  }

  Future<void> processPayment() async {
    if (phoneController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your phone number',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!MpesaService.to.validatePhoneNumber(phoneController.text)) {
      Get.snackbar(
        'Error',
        'Please enter a valid Kenyan phone number',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isProcessing.value = true;
      loadingMessage.value = 'Initiating M-Pesa payment...';

      // Check backend health first
      bool isBackendHealthy = await MpesaService.to.checkBackendHealth();
      if (!isBackendHealthy) {
        Get.snackbar(
          'Service Unavailable',
          'Payment service is currently unavailable. Please try again later.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Initiate payment via Django backend
      final result = await MpesaService.to.initiatePayment(
        booking: booking,
        customerPhone: phoneController.text.trim(),
        customerEmail: 'customer@example.com', // Get from user data
        customerName: booking.customerName,
        customerId: booking.customerId,
      );

      if (result != null && result['success'] == true) {
        loadingMessage.value = 'STK Push sent to your phone';

        // Start monitoring payment status
        _monitorPaymentStatus(result['checkout_request_id']);

        Get.snackbar(
          'Payment Initiated',
          'M-Pesa STK Push sent to your phone. Please enter your PIN to complete payment.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
      } else {
        String errorMessage = result?['error'] ?? 'Payment initiation failed';
        Get.snackbar(
          'Payment Failed',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Payment processing failed: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isProcessing.value = false;
      loadingMessage.value = '';
    }
  }

  Future<void> _monitorPaymentStatus(String checkoutRequestId) async {
    const maxAttempts = 20; // Check for up to 5 minutes (20 * 15 seconds)
    int attempts = 0;

    Timer.periodic(Duration(seconds: 15), (timer) async {
      attempts++;

      try {
        final result =
            await MpesaService.to.checkPaymentStatus(checkoutRequestId);

        if (result != null && result['success'] == true) {
          String status = result['status'];

          if (status == 'completed') {
            timer.cancel();
            final payment = MpesaService.to.currentPayment.value;
            if (payment != null) {
              await _handlePaymentSuccess(payment);
            }
          } else if (status == 'failed') {
            timer.cancel();
            Get.snackbar(
              'Payment Failed',
              'Payment was not completed. Please try again.',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            isProcessing.value = false;
            loadingMessage.value = '';
          }
        }
      } catch (e) {
        print('Error checking payment status: $e');
      }

      if (attempts >= maxAttempts) {
        timer.cancel();
        Get.snackbar(
          'Payment Timeout',
          'Payment verification timed out. The payment may still complete. Check your M-Pesa messages.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        isProcessing.value = false;
        loadingMessage.value = '';
      }
    });
  }

  Future<void> _handlePaymentSuccess(PaymentModel payment) async {
    try {
      isProcessing.value = false;
      loadingMessage.value = '';

      // Navigate to success page
      Get.toNamed(Routes.PAYMENT_SUCCESS, arguments: {
        'paymentId': payment.id,
        'amount': payment.amount,
        'serviceName': booking.serviceName,
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to process payment success: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }
}
