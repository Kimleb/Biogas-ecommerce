# Paystack Payment Integration Setup Guide

## Overview
This app uses Paystack for payment processing with support for M-Pesa and Card payments.

## Prerequisites
1. Paystack account (https://paystack.co)
2. Flutter Paystack SDK (already added to pubspec.yaml)
3. Firebase Realtime Database setup

## Setup Steps

### 1. Get Paystack API Keys

1. Sign up or login to your Paystack dashboard
2. Go to Settings → API Keys
3. Copy your **Public Key** and **Secret Key**
4. For testing, use **Test Keys**
5. For production, use **Live Keys**

### 2. Configure API Keys

Edit `lib/config/paystack_config.dart`:

```dart
// Test keys (replace with your actual Paystack test keys)
static const String publicKey = 'pk_test_your_actual_test_public_key_here';
static const String secretKey = 'sk_test_your_actual_test_secret_key_here';

// Production keys (uncomment and replace with actual production keys)
// static const String publicKey = 'pk_live_your_actual_live_public_key_here';
// static const String secretKey = 'sk_live_your_actual_live_secret_key_here';
```

### 3. Firebase Database Structure

Create the following structure in your Firebase Realtime Database:

```
{
  "payments": {
    "pay_1234567890_abc123": {
      "id": "pay_1234567890_abc123",
      "bookingId": "booking_123",
      "userId": "user_456",
      "technicianId": "tech_789",
      "amount": 2500.0,
      "currency": "KES",
      "paymentType": "payNow",
      "status": "completed",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "paidAt": "2024-01-01T12:05:00.000Z",
      "description": "Payment for Biogas Service",
      "reference": "paystack_reference_123",
      "verificationData": {...}
    }
  }
}
```

### 4. Payment Flow

#### M-Pesa Payment Flow:
1. User selects M-Pesa payment
2. Enter phone number
3. Initialize payment via Paystack
4. User receives OTP on phone
5. User enters OTP
6. Payment is completed
7. Booking status updated to "paid"

#### Card Payment Flow:
1. User selects Card payment
2. Initialize payment via Paystack
3. User redirected to Paystack payment page
4. User completes payment
5. Payment verified
6. Booking status updated to "paid"

### 5. Testing

#### Test M-Pesa:
- Use test phone number: `+254712345678`
- Use test OTP: `123456`

#### Test Card:
- Use test card details provided by Paystack
- Any valid test card number with future expiry date

### 6. Security Considerations

1. **Never commit actual API keys** to version control
2. Use environment variables for production keys
3. Enable webhook verification in production
4. Implement proper error handling
5. Log all payment transactions for audit

### 7. Webhook Setup (Production)

1. In Paystack dashboard, go to Settings → Webhooks
2. Add webhook URL: `https://yourapp.com/api/paystack/webhook`
3. Enable events: `charge.success`, `charge.failed`
4. Implement webhook endpoint to verify and update payments

### 8. Common Issues & Solutions

#### Issue: "Invalid email format"
- Solution: Ensure email is valid and registered with Paystack

#### Issue: "Amount too small"
- Solution: Minimum amount is typically 100 KES

#### Issue: "Phone number format invalid"
- Solution: Use format: `+254712345678`

#### Issue: "Service not found"
- Solution: Ensure PaystackService is registered in main.dart

### 9. Configuration Options

Edit `lib/config/paystack_config.dart` to customize:

- **Currency**: Change from KES to other supported currencies
- **Platform fee**: Adjust percentage (default 5%)
- **Technician commission**: Adjust percentage (default 80%)
- **Payment limits**: Set min/max transaction amounts
- **Timeouts**: Adjust payment and OTP timeouts

### 10. Support

For Paystack-specific issues:
- Paystack documentation: https://paystack.co/docs
- Paystack support: support@paystack.co

For app-specific issues:
- Check Firebase database rules
- Verify API key configuration
- Check network connectivity
- Review app logs for error details

## Features Implemented

✅ M-Pesa payment integration
✅ Card payment integration  
✅ OTP verification for M-Pesa
✅ Payment status tracking
✅ Firebase database integration
✅ Booking status updates
✅ Payment history
✅ Technician earnings calculation
✅ Refund functionality
✅ Error handling and validation
✅ Configuration management

## Next Steps

1. Replace placeholder API keys with actual keys
2. Test payment flow thoroughly
3. Set up production webhooks
4. Implement additional security measures
5. Add comprehensive logging
6. Set up monitoring and alerts
