import 'package:flutter/material.dart';
import 'package:visualization/structure/boxbutton.dart';
import 'package:visualization/theme/colors.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: AppColors.grey,
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Image.asset("assets/cancer.png"),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 60, bottom: 20),
                child: const Text(
                  'CANCER IN KENYA',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'CANCER SUMMARY',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 32),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                margin: const EdgeInsets.only(right: 10),
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Next',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 40),
                child: BoxButton(
                    text: 'Get Started',
                    onClick: () {
                      Navigator.of(context).pushReplacementNamed('login');
                    }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
