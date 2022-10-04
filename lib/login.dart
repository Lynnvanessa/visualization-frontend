import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

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
              margin: const EdgeInsets.only(
                top: 40,
              ),
              child: Image.asset('assets/watu.png'),
            ),
            const SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(top: 40, bottom: 40),
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
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
              padding: const EdgeInsets.only(top: 40, bottom: 40),
              child: TextFormField(
                decoration: const InputDecoration(
                    icon: Icon(
                      Icons.password,
                      color: Colors.black,
                    ),
                    border: OutlineInputBorder(),
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
                onPressed: () {},
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
                          Navigator.of(context).pushReplacementNamed('signup');
                        },
                    ),
                  ])),
            ),
          ],
        ),
      ),
    ));
  }
}
