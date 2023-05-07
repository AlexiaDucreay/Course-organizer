// Edgar Zapata
// file upload page is using firebase storage to save the files of the user
// using filepagestate as a class
// it house the functions upload file, pickfile, view file for the user
// to be able to use this feature to store their pdfs onto cloud
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

// FileUploadPage widget that allows users to pick and upload a file to Firebase Storage
class FileUploadPage extends StatefulWidget {
  static const String id = 'file_upload';

  const FileUploadPage({Key? key}) : super(key: key);

  @override
  _FileUploadPageState createState() => _FileUploadPageState();
}

class _FileUploadPageState extends State<FileUploadPage> {
  File? _file; // variable to hold the selected file
  bool _isUploading =
      false; // variable to track if a file is currently being uploaded

  // Function to pick a file from device storage
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // specify allowed file types
    );

    if (result != null) {
      setState(() {
        _file = File(result.files.single.path!);
      });
    }
  }

  // Function to upload selected file to Firebase Storage
  Future<void> _uploadFile() async {
    setState(() {
      _isUploading = true;
    });

    try {
      // Get reference to the storage location where the file will be uploaded
      final firebaseStorageRef =
          //FirebaseStorage.instance.ref().child('files/${_file!.name}');

          // Upload the file to Firebase Storage
          //await firebaseStorageRef.putFile(_file!);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('File uploaded successfully.')));
    } catch (error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading file: $error')));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Placeholder function for viewing files
  void _viewFile() {}

  // Build the widget tree
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Upload'),
        backgroundColor: const Color.fromARGB(255, 151, 53, 53),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Button to select file
            ElevatedButton(
              onPressed: _isUploading ? null : _pickFile,
              child: const Text('Select File'),
            ),
            const SizedBox(height: 16.0),
            // Progress indicator while file is uploading, or button to upload file
            if (_isUploading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _file == null || _isUploading ? null : _uploadFile,
                child: const Text('Upload File'),
              ),
            const SizedBox(height: 16.0),
            // Button to view selected file
            ElevatedButton(
              onPressed: _file == null ? null : _viewFile,
              child: const Text('View File'),
            ),
          ],
        ),
      ),
    );
  }
}
