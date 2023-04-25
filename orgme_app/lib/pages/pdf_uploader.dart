import 'package:flutter/material.dart'; // importing the Flutter material package
import 'dart:io'; // importing the dart:io package for file operations
import 'package:file_picker/file_picker.dart'; // importing the file_picker package for file picking
import 'package:flutter_file_view/flutter_file_view.dart';

class PdfUploadPage extends StatefulWidget {
  static const String id = 'pdf_upload_page';
  const PdfUploadPage({super.key});

  @override
  State<PdfUploadPage> createState() => _PdfUploadPageState();
}

class _PdfUploadPageState extends State<PdfUploadPage> {
  File? _pdfFile; // variable to hold the selected PDF file

  Future<void> _pickPDF() async {
    // function to pick a PDF file from device storage
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _pdfFile = File(result.files.single.path!);
      });
    }
  }

  void _viewPDF() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Upload'),
        backgroundColor: const Color.fromARGB(255, 151, 53, 53),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickPDF,
              child: const Text('Select PDF'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _pdfFile == null ? null : _viewPDF,
              child: const Text('View PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
