# 🔑 Getting Daraja API Credentials

The app is currently using placeholder credentials. You need to get your own valid credentials from Safaricom.

## 🚀 Quick Setup Steps:

### 1. Go to Safaricom Developer Portal
Visit: https://developer.safaricom.co.ke/

### 2. Create Account/Login
- Sign up or login with your email
- Verify your email address

### 3. Create New App
- Click "Create New App"
- Give it a name (e.g., "Biogas App")
- Add a description
- Click "Create"

### 4. Add M-Pesa APIs
- Click on your newly created app
- Click "Add API"
- Select these APIs:
  - ✅ **M-Pesa STK Push API**
  - ✅ **M-Pesa B2C API** (optional)
  - ✅ **M-Pesa Transaction Status API** (optional)
- Click "Add"

### 5. Get Your Credentials
- Go to your app dashboard
- You'll see:
  - **Consumer Key**: Copy this
  - **Consumer Secret**: Copy this

### 6. Update Your Credentials
In `lib/app/data/services/daraja_service.dart`, update these lines:

```dart
static const String _consumerKey = 'YOUR_CONSUMER_KEY_HERE';
static const String _consumerSecret = 'YOUR_CONSUMER_SECRET_HERE';
```

### 7. Test Credentials
Run the app and check console logs. You should see:
```
OAuth Response Status: 200
OAuth Response Body: {"access_token": "...", "expires_in": "3599"}
OAuth Token obtained successfully
```

## 🧪 Sandbox vs Production

### Sandbox (for testing):
- Use the credentials from your developer portal app
- Test shortcode: `174379`
- Test passkey: `bfb279c9a6ffbdf4f8b4c3e8e3c7b3c8e3c7b3c8e3c7b3c8e3c7b3c8e3c7b3c`

### Production (for live payments):
- Contact Safaricom to get production credentials
- Use your real business shortcode
- Use your production passkey

## 🔍 Troubleshooting

### If you get 400 status with empty response:
- ✅ Check Consumer Key and Secret are correct
- ✅ Make sure there are no extra spaces
- ✅ Verify your app has M-Pesa STK Push API enabled

### If you get 401 status:
- ✅ Credentials are invalid
- ✅ Re-check Consumer Key and Secret

### If you get 403 status:
- ✅ API not enabled for your app
- ✅ Go back and add M-Pesa STK Push API

## 📱 Testing M-Pesa Flow

Once OAuth works:
1. Enter phone number: +254712345678
2. Click "Pay with M-Pesa"
3. You'll receive STK Push prompt
4. Enter PIN to complete payment

## 🆘 Still Having Issues?

1. **Check API Console**: https://developer.safaricom.co.ke/API-Console
2. **Test OAuth directly**: Use API Console to test credentials
3. **Contact Support**: Reach out to Safaricom developer support

The enhanced error handling will show you exactly what's wrong with your credentials, making debugging much easier!
