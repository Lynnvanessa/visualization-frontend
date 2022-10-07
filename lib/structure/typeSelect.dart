import 'package:flutter/material.dart';

import '../theme/colors.dart';

void main() => runApp(const TypeSelect());

const List<String> list = <String>['One', 'Two', 'Three', 'Four'];

class TypeSelect extends StatefulWidget {
  const TypeSelect({Key? key}) : super(key: key);

  @override
  State<TypeSelect> createState() => _TypeSelectState();
}

class _TypeSelectState extends State<TypeSelect> {
  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      width: 300,
      alignment: Alignment.topRight,
      decoration: const BoxDecoration(
          shape: BoxShape.rectangle, color: AppColors.lightgrey),
      child: DropdownButton<String>(
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
              value: value,
              child: Text(value),
            );
          }).toList()),
    );
  }
}
