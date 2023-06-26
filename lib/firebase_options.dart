// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBE9ovZ3V4SaJYq0xNuR7ro6_kd4vv-oLs',
    appId: '1:471372471791:web:7000fe68e5d7f2dc406a1a',
    messagingSenderId: '471372471791',
    projectId: 'openaiintern',
    authDomain: 'openaiintern.firebaseapp.com',
    storageBucket: 'openaiintern.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBeIWuoPs0DVQdgx0incDWfv1IsZpZgiQM',
    appId: '1:471372471791:android:0e395f509b323670406a1a',
    messagingSenderId: '471372471791',
    projectId: 'openaiintern',
    storageBucket: 'openaiintern.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAY60IQMqzyLeq1aBlRULBDLBIoFNKehuk',
    appId: '1:471372471791:ios:d0683169bad26e24406a1a',
    messagingSenderId: '471372471791',
    projectId: 'openaiintern',
    storageBucket: 'openaiintern.appspot.com',
    iosClientId: '471372471791-or3gs7k57u3usiu5vl1rucvlo7alegka.apps.googleusercontent.com',
    iosBundleId: 'com.example.openai',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAY60IQMqzyLeq1aBlRULBDLBIoFNKehuk',
    appId: '1:471372471791:ios:9776ef370e597970406a1a',
    messagingSenderId: '471372471791',
    projectId: 'openaiintern',
    storageBucket: 'openaiintern.appspot.com',
    iosClientId: '471372471791-38oebm70kmbibuoun3rqcimkduq2h5jm.apps.googleusercontent.com',
    iosBundleId: 'com.example.openai.RunnerTests',
  );
}