import 'package:flutter/material.dart';
import 'package:visualization/structure/select.dart';
import 'package:visualization/structure/typeSelect.dart';
import 'package:visualization/theme/colors.dart';

class Visualization extends StatelessWidget {
  const Visualization({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.grey,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            child: const Text(
              'Select variables',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Wrap(
              spacing: 10,
              children: const [Select(), Select()],
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            child: const Text(
              'Select visualization type',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
          ),
          Container(alignment: Alignment.center, child: const TypeSelect()),
        ],
      ),
    );
  }
}
