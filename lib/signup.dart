import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Signup extends StatelessWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                decoration: const InputDecoration(
                    icon: Icon(
                      Icons.mail,
                      color: Colors.black,
                    ),
                    border: OutlineInputBorder(),
                    hintText: 'Email'),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 15),
                child: TextFormField(
                  decoration: const InputDecoration(
                      icon: Icon(
                        Icons.person,
                        color: Colors.black,
                      ),
                      border: OutlineInputBorder(),
                      hintText: 'First name'),
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(
                    icon: Icon(
                      Icons.person,
                      color: Colors.black,
                    ),
                    border: OutlineInputBorder(),
                    hintText: 'Last name'),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 15),
                child: TextFormField(
                  decoration: const InputDecoration(
                      icon: Icon(
                        Icons.lock,
                        color: Colors.black,
                      ),
                      border: OutlineInputBorder(),
                      hintText: 'Password'),
                  obscureText: true,
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(
                    icon: Icon(
                      Icons.lock,
                      color: Colors.black,
                    ),
                    border: OutlineInputBorder(),
                    hintText: 'Confirm password'),
                obscureText: true,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 15),
                child: Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('details');
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
                            Navigator.of(context).pushReplacementNamed('login');
                          },
                      ),
                    ])),
              )
            ],
          ),
        ),
      ),
    );
  }
}
