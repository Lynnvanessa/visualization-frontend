import 'package:flutter/material.dart';
import 'package:visualization/theme/colors.dart';

class CodeInput extends StatelessWidget {
  const CodeInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: 50,
      height: 60,
      child: TextFormField(
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: const InputDecoration(
          counter: SizedBox(),
          filled: true,
          fillColor: AppColors.lightgrey,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.lightgrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.lightgrey),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.lightgrey),
          ),
        ),
      ),
    );
  }
}
