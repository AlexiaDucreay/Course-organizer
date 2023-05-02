// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';

// class for textfield to be used in any dart file
class MyTextField extends StatelessWidget {
  final contoller;
  final String hinttext;
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.contoller,
    required this.hinttext,
    required this.obscureText,
  });

  /// textfield UI build
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: TextField(
        controller: contoller,
        obscureText: obscureText,
        decoration: InputDecoration(
            labelStyle: const TextStyle(color: Colors.white),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade600),
            ),
            fillColor: Colors.grey.shade200,
            filled: true,
            hintText: hinttext,
            hintStyle: const TextStyle(
              color: Colors.black,
              fontSize: 18,
            )),
      ),
    );
  }
}
