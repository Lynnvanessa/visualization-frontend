import 'package:flutter/material.dart';
import 'package:visualization/structure/code_input.dart';

class Verification extends StatelessWidget {
  const Verification({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 40),
                child: Image.asset('assets/watu.png')),
            Container(
              alignment: Alignment.topLeft,
              margin: const EdgeInsets.only(top: 20, bottom: 20),
              child: const Text(
                'Verification Code',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
              ),
            ),
            Wrap(
              spacing: 20,
              children: const [
                CodeInput(),
                CodeInput(),
                CodeInput(),
                CodeInput()
              ],
            ),
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(top: 30),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('resetpassword');
                },
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0))),
                child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: const Text('Verifying')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
