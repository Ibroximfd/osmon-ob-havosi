// Generated from the Firebase project `osmon-ob-havo` (firebase apps:sdkconfig).
// These are client identifiers, not secrets: access is governed by the
// project's security rules and API restrictions.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;

abstract final class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => switch (defaultTargetPlatform) {
    TargetPlatform.iOS => ios,
    _ => android,
  };

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDo_My9un3lbwLAhydMnZbRIs8HjGwY4sE',
    appId: '1:275020379230:android:1b89537ce2d07b8c1d70cf',
    messagingSenderId: '275020379230',
    projectId: 'osmon-ob-havo',
    storageBucket: 'osmon-ob-havo.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD7yWCN_thwx2-_mjYQim9X6YHH12_-7m0',
    appId: '1:275020379230:ios:494d309a79d134a01d70cf',
    messagingSenderId: '275020379230',
    projectId: 'osmon-ob-havo',
    storageBucket: 'osmon-ob-havo.firebasestorage.app',
    iosBundleId: 'uz.osmon.osmonUzbekistonObHavosi',
  );
}
