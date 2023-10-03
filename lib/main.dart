import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:visualization/feed.dart';
import 'package:visualization/firebase_options.dart';
import 'package:visualization/forgotpassword.dart';
import 'package:visualization/home.dart';
import 'package:visualization/login.dart';
import 'package:visualization/resetpassword.dart';
import 'package:visualization/signup.dart';
import 'package:visualization/structure/code_input.dart';
import 'package:visualization/upload.dart';
import 'package:visualization/verification.dart';
import 'package:visualization/visualization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        'home': (context) => const Home(),
        'login': (context) => const Login(),
        'signup': (context) => const Signup(),
        'forgotpassword': (context) => const ForgotPassword(),
        'resetpassword': (context) => const ResetPassword(),
        'verification': (context) => const Verification(),
        'vcode': (context) => const CodeInput(),
        'visualization': (context) => const Visualization(),
        'upload': (context) => const UploadFile(),
        'feed': (context) => const FeedScreen(),
      },
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: FirebaseAuth.instance.currentUser == null ? 'home' : 'feed',
    );
  }
}
