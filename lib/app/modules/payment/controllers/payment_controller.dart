import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/paystack_service.dart';
import '../../../data/models/payment_model.dart';
import '../../../data/models/booking_model.dart';
import '../../payment/views/payment_success_view.dart';

class PaymentController extends GetxController {
  final isLightTheme = true.obs;
  final isLoading = false.obs;
  final loadingMessage = ''.obs;
  final isProcessing = false.obs;
  final selectedPaymentMethod = PaymentMethod.mpesa.obs;
  final phoneController = TextEditingController();

  // Sample data - replace with actual booking data
  final BookingModel? booking = BookingModel(
    id: 'booking_123',
    customerId: 'customer_456',
    customerName: 'John Doe',
    serviceId: 'service_001',
    serviceName: 'Biogas Installation',
    technicianId: 'tech_789',
    bookingDate: DateTime.now(),
    serviceDate: DateTime.now().add(Duration(days: 1)),
    status: 'pending',
    totalPrice: 2650.0,
    address: '123 Main St, Nairobi, Kenya',
    selectedParts: [],
  );

  // Payment amounts
  double get serviceFee => 2500.0;
  double get platformFee => 150.0;
  double get totalAmount => serviceFee + platformFee;

  @override
  void onInit() {
    super.onInit();
    // Pre-fill phone number if available from user profile
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
        booking: booking!,
        email: 'customer@example.com',
        amount: totalAmount,
        paymentType: PaymentType.payNow,
        paymentMethod: PaymentMethod.mpesa,
        phoneNumber: phoneController.text,
      );

      if (payment != null) {
        // Show OTP dialog
        _showOtpDialog(payment.reference!);
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
        booking: booking!,
        email: 'customer@example.com',
        amount: totalAmount,
        paymentType: PaymentType.payNow,
        paymentMethod: PaymentMethod.card,
      );

      if (payment != null) {
        // Handle card payment (redirect to authorization URL)
        Get.snackbar(
          'Card Payment',
          'Redirecting to payment page...',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
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

  void _showOtpDialog(String reference) {
    final otpController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.sms, color: Color(0xFFFF8C00)),
            SizedBox(width: 12),
            Text('Enter OTP'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter the 6-digit OTP sent to your M-Pesa number',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
              decoration: InputDecoration(
                hintText: '000000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _submitOtp(reference, otpController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF8C00),
            ),
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitOtp(String reference, String otp) async {
    Get.back(); // Close dialog

    try {
      isLoading.value = true;
      loadingMessage.value = 'Verifying OTP...';

      final payment = await PaystackService.to.submitMpesaOtp(reference, otp);

      if (payment != null) {
        // Navigate to success page
        Get.off(() => PaymentSuccessView(
              paymentId: payment.id,
              amount: payment.amount,
              serviceName: booking!.serviceName,
            ));
      }
    } catch (e) {
      Get.snackbar(
        'OTP Verification Failed',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }
}
