// File generated for Firebase initialization in Spendly app
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSySpendlyWebApiKeyFake1234567890abcdef',
    appId: '1:102938475610:web:spendlyauth0987654321',
    messagingSenderId: '102938475610',
    projectId: 'spendly-finance-app',
    authDomain: 'spendly-finance-app.firebaseapp.com',
    storageBucket: 'spendly-finance-app.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSySpendlyAndroidApiKey1234567890abcdef',
    appId: '1:102938475610:android:spendlyauth0987654321',
    messagingSenderId: '102938475610',
    projectId: 'spendly-finance-app',
    storageBucket: 'spendly-finance-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSySpendlyIosApiKey1234567890abcdef',
    appId: '1:102938475610:ios:spendlyauth0987654321',
    messagingSenderId: '102938475610',
    projectId: 'spendly-finance-app',
    storageBucket: 'spendly-finance-app.appspot.com',
    iosBundleId: 'com.spendly.app.frontend',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSySpendlyIosApiKey1234567890abcdef',
    appId: '1:102938475610:ios:spendlyauth0987654321',
    messagingSenderId: '102938475610',
    projectId: 'spendly-finance-app',
    storageBucket: 'spendly-finance-app.appspot.com',
    iosBundleId: 'com.spendly.app.frontend',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSySpendlyWebApiKeyFake1234567890abcdef',
    appId: '1:102938475610:web:spendlyauth0987654321',
    messagingSenderId: '102938475610',
    projectId: 'spendly-finance-app',
    authDomain: 'spendly-finance-app.firebaseapp.com',
    storageBucket: 'spendly-finance-app.appspot.com',
  );
}
