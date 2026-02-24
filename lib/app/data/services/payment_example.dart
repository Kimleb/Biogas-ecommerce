/// Example usage of Paystack M-Pesa payment service
///
/// This file demonstrates how to use the Paystack service with M-Pesa payments
/// in your Flutter application.

import 'package:get/get.dart';
import 'paystack_service.dart';
import '../models/payment_model.dart';
import '../models/booking_model.dart';

class PaymentExample {
  /// Initialize M-Pesa payment for a service booking
  Future<void> initializeMpesaPayment() async {
    try {
      // Create a sample booking (replace with your actual booking data)
      final booking = BookingModel(
        id: 'booking_123',
        customerId: 'customer_456',
        customerName: 'John Doe',
        serviceId: 'service_789',
        serviceName: 'AC Repair Service',
        bookingDate: DateTime.now(),
        serviceDate: DateTime.now().add(Duration(days: 1)),
        status: 'pending',
        totalPrice: 2500.0,
        address: '123 Main St, Nairobi, Kenya',
      );

      // Initialize M-Pesa payment
      final payment = await PaystackService.to.initializeServicePayment(
        booking: booking,
        email: 'customer@example.com',
        amount: 2500.0, // Amount in KES
        paymentType: PaymentType.payNow,
        paymentMethod: PaymentMethod.mpesa,
        phoneNumber: '+254712345678', // Customer's M-Pesa phone number
      );

      if (payment != null) {
        print('Payment initialized: ${payment.reference}');

        // For M-Pesa, the customer will receive an OTP on their phone
        // You need to collect this OTP from the user and submit it

        // Example: Submit OTP (this would typically come from user input)
        // final completedPayment = await PaystackService.to.submitMpesaOtp(
        //   payment.reference!,
        //   '123456', // OTP entered by user
        // );
      }
    } catch (e) {
      print('Payment initialization failed: $e');
    }
  }

  /// Verify payment status
  Future<void> checkPaymentStatus(String reference) async {
    try {
      final payment = await PaystackService.to.verifyPayment(reference);

      if (payment != null) {
        print('Payment status: ${payment.status}');
        print('Paid at: ${payment.paidAt}');
      } else {
        print('Payment not found or still pending');
      }
    } catch (e) {
      print('Payment verification failed: $e');
    }
  }

  /// Handle M-Pesa OTP submission
  Future<void> submitMpesaOtp(String reference, String otp) async {
    try {
      final payment = await PaystackService.to.submitMpesaOtp(reference, otp);

      if (payment != null) {
        print('Payment completed successfully!');
        print('Payment ID: ${payment.id}');
        print('Amount: KES ${payment.amount}');

        // You can now proceed with booking confirmation
        // or any other post-payment logic
      } else {
        print('OTP submission failed or payment still pending');
      }
    } catch (e) {
      print('OTP submission error: $e');
    }
  }
}

/*
IMPORTANT SETUP NOTES:

1. Paystack Account Setup:
   - Sign up for a Paystack account at https://paystack.co
   - Enable M-Pesa payments in your dashboard
   - Get your secret and public keys

2. Environment Configuration:
   - Replace 'YOUR_PAYSTACK_SECRET_KEY' in paystack_service.dart
   - Consider using environment variables for security

3. M-Pesa Requirements:
   - Customer must have an active M-Pesa account
   - Phone number must be in format: +254XXXXXXXXX
   - Amount must be in KES (Kenyan Shillings)

4. Payment Flow:
   - Initialize payment with phone number
   - Customer receives OTP via SMS
   - Submit OTP to complete payment
   - Verify payment status

5. Testing:
   - Use Paystack's test mode for development
   - Test with real M-Pesa numbers in production

6. Error Handling:
   - Always wrap payment calls in try-catch blocks
   - Handle network errors gracefully
   - Provide user feedback for payment status

7. Security:
   - Never expose your secret key in client-side code
   - Use HTTPS for all API calls
   - Validate payment amounts server-side
*/
