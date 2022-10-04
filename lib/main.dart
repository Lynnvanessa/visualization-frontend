import 'package:flutter/material.dart';
import 'package:visualization/forgotpassword.dart';
import 'package:visualization/home.dart';
import 'package:visualization/login.dart';
import 'package:visualization/resetpassword.dart';
import 'package:visualization/signup.dart';

void main() {
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
        'forgotpassword': (context) => const Forgotpassword(),
        'resetpassword': (context) => const Resetpassword(),
      },
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: 'home',
    );
  }
}
