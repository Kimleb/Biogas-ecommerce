import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/paystack_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/payment_model.dart';
import '../../../data/models/booking_model.dart';
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
    if (selectedPaymentMethod.value == PaymentMethod.mpesa) {
      if (phoneController.text.isEmpty) {
        Get.snackbar(
          'Phone Number Required',
          'Please enter your M-Pesa phone number',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      await _processMpesaPayment();
    } else {
      await _processCardPayment();
    }
  }

  Future<void> _processMpesaPayment() async {
    try {
      isProcessing.value = true;

      final payment = await PaystackService.to.initializeServicePayment(
        booking: booking,
        email: userEmail,
        amount: totalAmount,
        paymentType: PaymentType.payNow,
        paymentMethod: PaymentMethod.mpesa,
        phoneNumber: phoneController.text,
      );

      if (payment != null) {
        final authUrl = PaystackService.to.getAuthorizationUrl(payment);
        if (authUrl != null) {
          // For now, simulate successful payment since we can't launch web view
          // In a real app, you would launch a web view with the authUrl
          await _simulatePaymentSuccess(payment.reference!);
        } else {
          Get.snackbar(
            'Payment Error',
            'No authorization URL received',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Payment Failed',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> _processCardPayment() async {
    try {
      isProcessing.value = true;

      final payment = await PaystackService.to.initializeServicePayment(
        booking: booking,
        email: userEmail,
        amount: totalAmount,
        paymentType: PaymentType.payNow,
        paymentMethod: PaymentMethod.card,
      );

      if (payment != null) {
        final authUrl = PaystackService.to.getAuthorizationUrl(payment);
        if (authUrl != null) {
          // For now, simulate successful payment since we can't launch web view
          // In a real app, you would launch a web view with the authUrl
          await _simulatePaymentSuccess(payment.reference!);
        } else {
          Get.snackbar(
            'Payment Error',
            'No authorization URL received',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Payment Failed',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> _simulatePaymentSuccess(String reference) async {
    // Simulate payment processing delay
    await Future.delayed(Duration(seconds: 2));

    // For demo purposes, create a successful payment without actual verification
    // since we're simulating the payment flow
    final simulatedPayment = PaymentModel(
      id: reference,
      bookingId: booking.id,
      userId: booking.customerId,
      technicianId: booking.technicianId,
      amount: totalAmount,
      currency: 'KES',
      paymentType: PaymentType.payNow,
      status: PaymentStatus.completed,
      createdAt: DateTime.now(),
      paidAt: DateTime.now(),
      description: 'Payment for ${booking.serviceName}',
      reference: reference,
    );

    // Navigate to success page with simulated payment data
    await _handlePaymentSuccess(simulatedPayment);
  }

  Future<void> _handlePaymentSuccess(PaymentModel payment) async {
    try {
      // For simulated payments, skip verification and proceed directly
      // For real payments, you would verify here

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
