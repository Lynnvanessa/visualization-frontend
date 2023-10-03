import 'package:flutter/material.dart';

import '../theme/colors.dart';

const List<String> list = <String>['One', 'Two', 'Three', 'Four'];

class Select extends StatefulWidget {
  const Select({Key? key}) : super(key: key);

  @override
  State<Select> createState() => _SelectState();
}

class _SelectState extends State<Select> {
  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      alignment: Alignment.topRight,
      decoration: const BoxDecoration(
          shape: BoxShape.rectangle, color: AppColors.lightgrey),
      child: DropdownButton<String>(
          alignment: Alignment.centerLeft,
          value: dropdownValue,
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Colors.black,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          elevation: 16,
          style: const TextStyle(color: Colors.black),
          onChanged: (String? value) {
            setState(() {
              dropdownValue = value!;
            });
          },
          items: list.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              alignment: Alignment.centerLeft,
              value: value,
              child: Text(value),
            );
          }).toList()),
    );
  }
}
