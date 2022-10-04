import 'package:flutter/material.dart';

class TextButton extends StatelessWidget {
  const TextButton({Key? key, required this.text, required this.onClick})
      : super(key: key);

  final String text;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
