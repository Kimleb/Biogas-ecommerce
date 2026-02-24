import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB-Lp7WLT7qJOXB6ZBk850_wp5m7GVeYdo',
    appId: '1:468132554019:web:d33ffd2a2766763cce5896',
    messagingSenderId: '468132554019',
    projectId: 'biogas-ecommerce',
    authDomain: 'biogas-ecommerce.firebaseapp.com',
    storageBucket: 'biogas-ecommerce.firebasestorage.app',
    measurementId: 'G-2ZS3J7LQJG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBMLBg5df1C_y8gmVIu1Pf0-cq4Q7axFWA',
    appId: '1:468132554019:android:c39b7fc3c254fae4ce5896',
    messagingSenderId: '468132554019',
    projectId: 'biogas-ecommerce',
    storageBucket: 'biogas-ecommerce.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDfQOt285WQ0eN5jIHGrmxOwCalFYK6eTo',
    appId: '1:468132554019:ios:b2afc3539928a9a2ce5896',
    messagingSenderId: '468132554019',
    projectId: 'biogas-ecommerce',
    storageBucket: 'biogas-ecommerce.firebasestorage.app',
    iosBundleId: 'com.biogas.services',
  );
}
