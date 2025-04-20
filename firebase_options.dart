
// File generated manually for Firebase integration

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web is not supported yet.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD5PqsMDrH_S7j4FR3G_0-QyVwdvRPq32k',
    appId: '1:33565884703:android:0be72d6c4f2f4bf3b0f02a',
    messagingSenderId: '33565884703',
    projectId: 'healthapp-backend-2e17a',
    storageBucket: 'healthapp-backend-2e17a.firebasestorage.app',
  );
}
