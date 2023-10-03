import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text('Available Records'),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('records').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text('Something went wrong'),
              );
            }

            final data = snapshot.data as QuerySnapshot<Map<String, dynamic>>;
            return ListView.builder(
              itemCount: data.size,
              itemBuilder: (context, index) {
                final doc = data.docs[index];
                final record = {...doc.data(), 'id': doc.id};
                final timestamp = int.tryParse(record['timestamp'] ?? '');
                String? formattedDate;
                if (timestamp != null) {
                  final date =
                      DateTime.fromMillisecondsSinceEpoch(timestamp ?? 0);
                  formattedDate = DateFormat('dd-MM-yyyy').format(date);
                }
                return ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, 'visualization',
                        arguments: record);
                  },
                  title: Text(record['fileName']),
                  subtitle: Text(record['description']),
                  trailing: formattedDate != null ? Text(formattedDate) : null,
                );
              },
            );
          },
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                iconColor: ModalRoute.of(context)!.settings.name == 'feed'
                    ? Colors.blue
                    : null,
                textColor: ModalRoute.of(context)!.settings.name == 'feed'
                    ? Colors.blue
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  if (ModalRoute.of(context)!.settings.name == 'feed') {
                    return;
                  }

                  Navigator.pushNamedAndRemoveUntil(
                      context, 'feed', (route) => false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: const Text('Upload'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'upload');
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  FirebaseAuth.instance.signOut().then((value) {
                    Navigator.pop(context);
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      'home',
                      (route) => false,
                    );
                  });
                },
              ),
            ],
          ),
        ));
  }
}
