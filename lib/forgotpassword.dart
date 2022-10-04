import 'package:flutter/material.dart';

class Forgotpassword extends StatelessWidget {
  const Forgotpassword({Key? key}) : super(key: key);

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
                margin: const EdgeInsets.only(left: 20, right: 20, top: 30),
                child: Image.asset("assets/watu.png"),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 15, bottom: 15),
                child: Text(
                  'Forgot password?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                ),
              ),
              const Text(
                'Dont worry! It happents.Please enter your email.',
                style: TextStyle(fontSize: 20),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 50),
                child: TextFormField(
                  decoration: const InputDecoration(
                      icon: Icon(
                        Icons.mail,
                        color: Colors.black,
                      ),
                      border: OutlineInputBorder(),
                      hintText: 'email'),
                ),
              ),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('verification');
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0))),
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: const Text('submit'),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
