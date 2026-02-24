# Google Sign-In Setup Guide

This guide will help you complete the Google Sign-In setup for your Biogas Services app.

## 🔧 What We've Fixed

### 1. Android Configuration ✅
- Cleaned up AndroidManifest.xml
- Removed unnecessary metadata that was causing conflicts
- Added proper intent queries for Google Sign-In

### 2. iOS Configuration ✅
- Updated Info.plist with correct bundle display name
- Added URL scheme for Google Sign-In callback
- Configured proper CFBundleURLTypes

### 3. Code Improvements ✅
- Made GoogleSignIn nullable with proper initialization
- Added comprehensive error handling
- Improved debugging with detailed console logs
- Fixed null safety issues throughout the auth service

## 🚀 Next Steps to Complete Setup

### Step 1: Firebase Configuration
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (or create a new one)
3. Enable Authentication → Sign-in method → Google
4. Download `google-services.json` and place it in `android/app/`
5. Download `GoogleService-Info.plist` and place it in `ios/Runner/`

### Step 2: Google Cloud Console
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Enable "Google+ API" and "Google Identity Toolkit API"
4. Create OAuth 2.0 credentials:
   - Application type: "Web application"
   - Authorized redirect URIs: Add your app's package name

### Step 3: Update Configuration Files

#### Android (google-services.json)
```json
{
  "project_info": {
    "project_number": "YOUR_PROJECT_NUMBER",
    "project_id": "YOUR_PROJECT_ID"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "YOUR_APP_ID",
        "android_client_info": {
          "package_name": "com.biogas.services"
        }
      },
      "oauth_client": [
        {
          "client_id": "YOUR_ANDROID_CLIENT_ID",
          "client_type": 3
        }
      ]
    }
  ]
}
```

#### iOS (GoogleService-Info.plist)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CLIENT_ID</key>
    <string>YOUR_IOS_CLIENT_ID</string>
    <key>REVERSED_CLIENT_ID</key>
    <string>YOUR_REVERSED_CLIENT_ID</string>
    <key>API_KEY</key>
    <string>YOUR_API_KEY</string>
    <key>GCM_SENDER_ID</key>
    <string>YOUR_SENDER_ID</string>
    <key>PLIST_VERSION</key>
    <string>1</string>
    <key>BUNDLE_ID</key>
    <string>com.biogas.services</string>
</dict>
</plist>
```

### Step 4: Testing
1. Run the app on a physical device (Google Sign-In doesn't work on simulator)
2. Try signing in with Google
3. Check console logs for detailed error messages

## 🐛 Common Issues & Solutions

### Issue: "Google Sign-In is not available"
**Solution**: Ensure Google Sign-In is properly initialized and the device has Google Play Services.

### Issue: "Web client type is required"
**Solution**: Add a Web OAuth 2.0 client in Google Cloud Console.

### Issue: "Developer error for package"
**Solution**: Ensure SHA-1 fingerprint is added to Firebase console.

### Issue: "Network error"
**Solution**: Check internet connection and ensure device time is correct.

## 📱 Testing Checklist

- [ ] App runs without crashes
- [ ] Google Sign-In button appears
- [ ] Google Sign-In flow starts on button press
- [ ] User can select Google account
- [ ] Authentication completes successfully
- [ ] User is redirected to correct screen
- [ ] User data is saved to Firebase

## 🔍 Debugging

Enable debug logging by adding this to your main.dart:
```dart
import 'package:flutter/foundation.dart';

void main() {
  if (kDebugMode) {
    // Enable debug logging
  }
  runApp(MyApp());
}
```

## 📞 Support

If you still face issues:
1. Check the console logs for detailed error messages
2. Ensure all configuration files are correctly placed
3. Verify Firebase and Google Cloud console settings
4. Test on a physical device with Google Play Services

## 🎉 Success Indicators

When Google Sign-In is working correctly:
- Console shows "Google Sign-In initialized successfully"
- User can select their Google account
- Authentication completes without errors
- User data appears in Firebase Database
- App navigates to the main screen
