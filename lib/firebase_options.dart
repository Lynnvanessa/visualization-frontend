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
    apiKey: 'AIzaSyBCURVt8i10iuLhxuSsI7sft6KxzK8fVVY',
    appId: '1:1043811621530:web:1e968104294796b7a65d23',
    messagingSenderId: '1043811621530',
    projectId: 'visualization-d3e4c',
    authDomain: 'visualization-d3e4c.firebaseapp.com',
    storageBucket: 'visualization-d3e4c.appspot.com',
    measurementId: 'G-FZTKHB7QE3',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCTOCkB1Nji8YVZSupy8IteQmsyhxToObQ',
    appId: '1:1043811621530:android:3c7ae65b7c61e5caa65d23',
    messagingSenderId: '1043811621530',
    projectId: 'visualization-d3e4c',
    storageBucket: 'visualization-d3e4c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD0EZOXgG2-0YfGEddDiTCQ-ABMSCoErCo',
    appId: '1:1043811621530:ios:d95233b00ae4667ea65d23',
    messagingSenderId: '1043811621530',
    projectId: 'visualization-d3e4c',
    storageBucket: 'visualization-d3e4c.appspot.com',
    iosClientId: '1043811621530-l33iib3ikg00nhosgbauk3l05b2vitbn.apps.googleusercontent.com',
    iosBundleId: 'com.example.visualization',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD0EZOXgG2-0YfGEddDiTCQ-ABMSCoErCo',
    appId: '1:1043811621530:ios:d95233b00ae4667ea65d23',
    messagingSenderId: '1043811621530',
    projectId: 'visualization-d3e4c',
    storageBucket: 'visualization-d3e4c.appspot.com',
    iosClientId: '1043811621530-l33iib3ikg00nhosgbauk3l05b2vitbn.apps.googleusercontent.com',
    iosBundleId: 'com.example.visualization',
  );
}
