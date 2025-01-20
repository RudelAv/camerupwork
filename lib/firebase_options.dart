// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyBqQhPBFb_IWhGqUZQINLSyn9bNuEAiK3c',
    appId: '1:190825767758:web:0ac7018e427ae58574f41f',
    messagingSenderId: '190825767758',
    projectId: 'flutter-firebase-a48a3',
    authDomain: 'flutter-firebase-a48a3.firebaseapp.com',
    databaseURL: 'https://flutter-firebase-a48a3-default-rtdb.firebaseio.com',
    storageBucket: 'flutter-firebase-a48a3.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAMY6tJ-3cXMOhIBoFCjoQchUzK8IcvDGU',
    appId: '1:190825767758:android:d9f56a47072ddc6574f41f',
    messagingSenderId: '190825767758',
    projectId: 'flutter-firebase-a48a3',
    databaseURL: 'https://flutter-firebase-a48a3-default-rtdb.firebaseio.com',
    storageBucket: 'flutter-firebase-a48a3.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCn5GocM-KVWrPWJ16gBFpJb40uFUlpkzI',
    appId: '1:190825767758:ios:64dad1e4070ef46d74f41f',
    messagingSenderId: '190825767758',
    projectId: 'flutter-firebase-a48a3',
    databaseURL: 'https://flutter-firebase-a48a3-default-rtdb.firebaseio.com',
    storageBucket: 'flutter-firebase-a48a3.appspot.com',
    iosClientId: '190825767758-r87665eo174cknubh30d3ra5653q4tmn.apps.googleusercontent.com',
    iosBundleId: 'com.example.pfe',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCn5GocM-KVWrPWJ16gBFpJb40uFUlpkzI',
    appId: '1:190825767758:ios:64dad1e4070ef46d74f41f',
    messagingSenderId: '190825767758',
    projectId: 'flutter-firebase-a48a3',
    databaseURL: 'https://flutter-firebase-a48a3-default-rtdb.firebaseio.com',
    storageBucket: 'flutter-firebase-a48a3.appspot.com',
    iosClientId: '190825767758-r87665eo174cknubh30d3ra5653q4tmn.apps.googleusercontent.com',
    iosBundleId: 'com.example.pfe',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBqQhPBFb_IWhGqUZQINLSyn9bNuEAiK3c',
    appId: '1:190825767758:web:41b106c8d0a0383b74f41f',
    messagingSenderId: '190825767758',
    projectId: 'flutter-firebase-a48a3',
    authDomain: 'flutter-firebase-a48a3.firebaseapp.com',
    databaseURL: 'https://flutter-firebase-a48a3-default-rtdb.firebaseio.com',
    storageBucket: 'flutter-firebase-a48a3.appspot.com',
  );
}
