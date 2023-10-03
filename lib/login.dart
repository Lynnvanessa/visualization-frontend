import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/conts.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var email = "";
  var password = "";
  var access = "";
  var loading = false;
  Map<String, dynamic> errors = {};
  final formState = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: formState,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(
                  top: 40,
                ),
                child: Image.asset('assets/watu.png'),
              ),
              const SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(top: 40, bottom: 30),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 40),
                child: Text(
                  errors["detail"] ?? "",
                  style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ),
              TextFormField(
                onChanged: (value) {
                  email = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your email address";
                  }
                  return null;
                },
                decoration: InputDecoration(
                    errorText: errors["email"]?.join(","),
                    icon: const Icon(
                      Icons.mail,
                      color: Colors.black,
                    ),
                    border: const OutlineInputBorder(),
                    hintText: 'Email'),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 40),
                child: TextFormField(
                  onChanged: (value) {
                    password = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your password";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      errorText: errors["password"]?.join(","),
                      icon: const Icon(
                        Icons.password,
                        color: Colors.black,
                      ),
                      border: const OutlineInputBorder(),
                      hintText: 'Password'),
                  obscureText: true,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('forgotpassword');
                },
                child: Container(
                    width: double.infinity,
                    alignment: Alignment.centerRight,
                    child: const Text('Forgot password?')),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 30),
                child: ElevatedButton(
                  onPressed: loading
                      ? null
                      : () {
                          Login();
                          // Navigator.of(context).pushNamed('visualization');
                        },
                  child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: const Text('Login')),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: RichText(
                    text: TextSpan(
                        text: 'No account? ',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                        children: <TextSpan>[
                      TextSpan(
                        text: 'Register',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            print("register clicked");
                            Navigator.of(context)
                                .pushReplacementNamed('signup');
                          },
                      ),
                    ])),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  void Login() async {
    setState(() {
      errors = {};
    });
    if (!formState.currentState!.validate()) {
      return;
    }
    setState(() {
      loading = true;
    });
    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) {
      Navigator.of(context).pushReplacementNamed('feed');
    })
        .catchError((e) {
      print(e);
      setState(() {
        loading = false;
        errors = {"detail": "Invalid email or password"};
      });
    });
  }
}
