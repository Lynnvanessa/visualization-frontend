import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:visualization/utils/conts.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  var email = '';
  // ignore: non_constant_identifier_names
  var last_name = '';
  var firstname = '';
  var password = '';
  var confirmpassword = '';
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
                  margin: const EdgeInsets.only(left: 20, right: 20, top: 40),
                  child: Image.asset("assets/watu.png"),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: Text(
                    'Signup',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                  ),
                ),
                TextFormField(
                  onChanged: (value) {
                    email = value;
                  },
                  validator: (value) {
                    if (!EmailValidator.validate(value ?? "")) {
                      return 'Invalid email';
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
                  padding: const EdgeInsets.only(top: 15, bottom: 15),
                  child: TextFormField(
                    onChanged: (value) {
                      firstname = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "This field is required";
                      }

                      return null;
                    },
                    decoration: InputDecoration(
                        errorText: errors["first_name"]?.join(","),
                        icon: const Icon(
                          Icons.person,
                          color: Colors.black,
                        ),
                        border: const OutlineInputBorder(),
                        hintText: 'First name'),
                  ),
                ),
                TextFormField(
                  onChanged: (value) {
                    last_name = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "This field is required";
                    }

                    return null;
                  },
                  decoration: InputDecoration(
                      errorText: errors["last_name"]?.join(","),
                      icon: const Icon(
                        Icons.person,
                        color: Colors.black,
                      ),
                      border: const OutlineInputBorder(),
                      hintText: 'Last name'),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 15),
                  child: TextFormField(
                    onChanged: (value) {
                      password = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "This field is required";
                      }
                      if (value.length < 5) {
                        return "Password is too short";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        errorText: errors["password"]?.join(","),
                        icon: const Icon(
                          Icons.lock,
                          color: Colors.black,
                        ),
                        border: const OutlineInputBorder(),
                        hintText: 'Password'),
                    obscureText: true,
                  ),
                ),
                TextFormField(
                  onChanged: (value) {
                    confirmpassword = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "This field is required";
                    }
                    if (password != value) {
                      return "Passwords don't match";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      errorText: errors["conf_password"]?.join(","),
                      icon: const Icon(
                        Icons.lock,
                        color: Colors.black,
                      ),
                      border: const OutlineInputBorder(),
                      hintText: 'Confirm password'),
                  obscureText: true,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 15),
                  child: Container(
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: loading
                          ? null
                          : () {
                              signUp();
                              // Navigator.of(context).pushReplacementNamed('details');
                            },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: const Text('Continue'),
                      ),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: RichText(
                      text: TextSpan(
                          text: 'Already have account? ',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                          children: <TextSpan>[
                        TextSpan(
                          text: 'Login',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.of(context)
                                  .pushReplacementNamed('login');
                            },
                        ),
                      ])),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void signUp() async {
    if (!formState.currentState!.validate()) {
      return;
    }
    setState(() {
      loading = true;
      errors = {};
    });
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register/'),
        headers: {
          "content-type": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "first_name": firstname,
          "last_name": last_name,
          "password": password,
          "conf_password": confirmpassword,
        }),
      );
      print(response.body);
      if (response.statusCode == 200) {
        // save token
        // redirect to main screen
      } else if (response.statusCode == 400) {
        //read error and display
        setState(() {
          errors = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print(e);
    }
    setState(() {
      loading = false;
    });
  }
}
