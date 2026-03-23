# M-Pesa Daraja Integration Setup Guide

## Overview
This guide walks you through setting up the complete M-Pesa Daraja integration with Flutter frontend and Django backend.

## Prerequisites
- Flutter SDK
- Python 3.8+
- Safaricom Daraja API credentials

## 1. Flutter Frontend Setup

### Dependencies
Add these to your `pubspec.yaml`:
```yaml
dependencies:
  get: ^4.6.6
  http: ^1.6.0
  crypto: ^3.0.3
  firebase_database: ^10.4.0
  firebase_core: ^2.24.2
```

### Daraja Service Configuration
Update `lib/app/data/services/daraja_service.dart` with your credentials:

```dart
static const String _consumerKey = 'your_consumer_key';
static const String _consumerSecret = 'your_consumer_secret';
static const String _passkey = 'your_passkey';
static const String _shortcode = '174379'; // Test shortcode
static const String _baseUrl = 'https://sandbox.safaricom.co.ke';
static const String _callbackUrl = 'https://your-django-app.com/api/mpesa/callback/';
```

### Main.dart Registration
Register the Daraja service in your main.dart:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize services
  await Get.putAsync(() async => DarajaService());
  
  runApp(MyApp());
}
```

## 2. Django Backend Setup

### Environment Setup
```bash
cd django_backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### Environment Variables
Copy `.env.example` to `.env` and update:

```bash
cp .env.example .env
```

Update `.env` with your actual credentials:
```
DEBUG=True
SECRET_KEY=your-secret-key-here
ALLOWED_HOSTS=localhost,127.0.0.1,your-domain.com

MPESA_SHORTCODE=174379
MPESA_PASSKEY=your_actual_passkey
MPESA_CONSUMER_KEY=your_actual_consumer_key
MPESA_CONSUMER_SECRET=your_actual_consumer_secret
MPESA_CALLBACK_URL=https://your-domain.com/api/mpesa/callback/
```

### Database Setup
```bash
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser
```

### Run Server
```bash
python manage.py runserver
```

## 3. Getting Daraja API Credentials

1. Go to [Safaricom Developer Portal](https://developer.safaricom.co.ke/)
2. Create an account or log in
3. Create a new app
4. Add M-Pesa STK Push API
5. Note down your Consumer Key and Consumer Secret
6. For testing, use sandbox credentials:
   - Shortcode: 174379
   - Passkey: bfb279c9a6ffbdf4f8b4c3e8e3c7b3c8e3c7b3c8e3c7b3c8e3c7b3c8e3c7b3c

## 4. Testing the Integration

### Test Payment Flow:
1. Start Django backend: `python manage.py runserver`
2. Run Flutter app: `flutter run`
3. Navigate to payment page
4. Enter phone number (format: +254712345678)
5. Click "Pay with M-Pesa"
6. Check phone for STK Push prompt
7. Enter M-Pesa PIN to complete payment
8. Verify payment completion in app

### Test Callback Manually:
```bash
curl -X POST http://localhost:8000/api/mpesa/callback/ \
  -H "Content-Type: application/json" \
  -d '{
    "Body": {
      "stkCallback": {
        "MerchantRequestID": "test-merchant-id",
        "CheckoutRequestID": "ws_CO_123456789",
        "ResultCode": 0,
        "ResultDesc": "Success",
        "CallbackMetadata": {
          "Item": [
            {"Name": "Amount", "Value": 100},
            {"Name": "MpesaReceiptNumber", "Value": "ABC123XYZ"},
            {"Name": "PhoneNumber", "Value": "254712345678"},
            {"Name": "TransactionDate", "Value": "20230123123456"}
          ]
        }
      }
    }
  }'
```

## 5. Production Deployment

### Django Backend
1. Set `DEBUG=False` in production
2. Use PostgreSQL instead of SQLite
3. Configure HTTPS and proper domain
4. Set up proper CORS origins
5. Use environment variables for sensitive data

### Flutter App
1. Update callback URL to production domain
2. Use production Daraja API endpoints
3. Implement proper error handling
4. Add logging and analytics

## 6. API Endpoints

### Django Backend Endpoints:
- `POST /api/mpesa/callback/` - M-Pesa callback handler
- `GET /api/payments/` - List all payments
- `GET /api/payments/{checkout_request_id}/` - Get payment details
- `GET /api/bookings/` - List all bookings
- `GET /api/health/` - Health check

### Flutter Service Methods:
- `initializeServicePayment()` - Initiate M-Pesa STK Push
- `verifyPayment()` - Check payment status
- `processCallback()` - Handle payment callback

## 7. Troubleshooting

### Common Issues:
1. **STK Push not received**: Check phone number format (+254...)
2. **Callback not working**: Verify callback URL is accessible
3. **Payment timeout**: Check network connectivity and API credentials
4. **Database errors**: Ensure migrations are applied

### Debugging:
- Check Django logs: `python manage.py runserver --verbosity=2`
- Monitor payment status in Django admin: `/admin/`
- Test callback endpoint with curl commands
- Check Firebase Realtime Database for payment records

## 8. Security Considerations

1. Never commit API credentials to version control
2. Use HTTPS in production
3. Validate all callback data
4. Implement rate limiting
5. Add proper authentication for admin endpoints
6. Use environment variables for sensitive data

## 9. Monitoring and Analytics

1. Log all payment attempts and results
2. Monitor callback success rates
3. Track payment completion times
4. Set up alerts for failed payments
5. Monitor Django server health

This integration provides a complete M-Pesa payment solution with real-time callbacks and proper error handling.
