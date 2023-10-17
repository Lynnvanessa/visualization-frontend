import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UploadFile extends StatefulWidget {
  const UploadFile({super.key});

  @override
  State<UploadFile> createState() => _UploadFileState();
}

class _UploadFileState extends State<UploadFile> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  File? file;
  bool isUploading = false;
  TextEditingController fileNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  void _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx', 'xls'],
    );

    if (result != null) {
      final path = result.files.single.path;
      if (path == null) {
        return;
      }
      setState(() {
        file = File(path);
      });
    }
  }

  void _uploadData() async {
    if (file == null) {
      Fluttertoast.showToast(
        msg: 'Please select a Dataset',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }
    setState(() {
      isUploading = true;
    });
    // upload file to firebase storage
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('records')
        .child("${timestamp}_${file!.path.split('/').last}");
    try {
      await storageRef.putFile(file!);

      // upload file details to firestore
      final fileName = fileNameController.text;
      final description = descriptionController.text;
      final downloadUrl = await storageRef.getDownloadURL();
      await FirebaseFirestore.instance.collection('records').add({
        'fileName': fileName,
        'description': description,
        'downloadUrl': downloadUrl,
        'timestamp': timestamp,
      });
      // reset form
      fileNameController.clear();
      descriptionController.clear();
      setState(() {
        file = null;
      });
      Fluttertoast.showToast(
        msg: 'Dataset uploaded successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
      );
    }
    // catch other exceptions
    catch (e) {
      Fluttertoast.showToast(
        msg: "Error uploading record",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
      );
      print(e);
    }

    setState(() {
      isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: BackButton(
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Upload Dataset'),
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: isUploading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Form(
                key: formKey,
                child: Column(
                  children: [
                    // inputs for file name, description, and file
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Dataset Name',
                      ),
                      controller: fileNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the dataset name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      controller: descriptionController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the dataset description';
                        }
                        return null;
                      },
                    ),
                    // component to upload file
                    InkWell(
                      onTap: _selectFile,
                      child: Container(
                        margin: const EdgeInsets.only(top: 20, bottom: 10),
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          file == null
                              ? 'Select Dataset'
                              : 'Dataset Selected\n${file!.path.split('/').last}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    // button to upload file
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          _uploadData();
                        }
                      },
                      child: const Text('Upload'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
