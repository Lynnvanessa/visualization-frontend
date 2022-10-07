import 'package:flutter/material.dart';
import 'package:visualization/theme/colors.dart';

class Details extends StatefulWidget {
  const Details({Key? key}) : super(key: key);

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.grey,
        actions: [
          Container(
            alignment: Alignment.centerRight,
            margin:
                const EdgeInsets.only(top: 10, left: 50, right: 10, bottom: 10),
            width: 300,
            child: TextFormField(
              decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12.0),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12.0),
                    ),
                    borderSide: BorderSide(color: AppColors.lightgrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12.0),
                    ),
                    borderSide: BorderSide(color: AppColors.lightgrey),
                  ),
                  hintText: 'search'),
            ),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
          Container(
            margin: const EdgeInsets.only(top: 40),
            child: ListTile(
              title: const Text(
                'Profile',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              onTap: () {},
            ),
          ),
          ListTile(
            title: const Text(
              'Upload',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            onTap: () {},
          )
        ]),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsetsDirectional.only(top: 30, bottom: 20),
              child: const Text(
                'Data Available',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
              ),
            ),
            GestureDetector(
              onDoubleTap: () {
                Navigator.of(context).pushNamed('visualization');
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: const Text(
                      'cancer 1,',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  const Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
