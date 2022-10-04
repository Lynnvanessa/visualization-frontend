import 'package:flutter/material.dart';

class Resetpassword extends StatelessWidget {
  const Resetpassword({Key? key}) : super(key: key);

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
                padding: EdgeInsets.only(top: 15),
                child: Text(
                  'Reset Password',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: TextFormField(
                  decoration: const InputDecoration(
                      icon: Icon(
                        Icons.lock,
                        color: Colors.black,
                      ),
                      border: OutlineInputBorder(),
                      hintText: 'New password'),
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
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(left: 20, bottom: 20, top: 30),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0))),
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: const Text(
                      'submitting',
                    ),
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
