import 'package:flutter/material.dart';

class Signup extends StatelessWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
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
              padding: EdgeInsets.only(top: 30, bottom: 30),
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
            TextFormField(
              decoration: const InputDecoration(
                  icon: Icon(
                    Icons.person,
                    color: Colors.black,
                  ),
                  border: OutlineInputBorder(),
                  hintText: 'First name'),
            ),
            TextFormField(
              decoration: const InputDecoration(
                  icon: Icon(
                    Icons.lock,
                    color: Colors.black,
                  ),
                  border: OutlineInputBorder(),
                  hintText: 'Password'),
              obscureText: true,
            ),
          ],
        ),
      ),
    );
  }
}
