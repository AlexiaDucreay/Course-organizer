// ignore_for_file: avoid_print, duplicate_ignore
/// todo
///
///
// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orgme_app/pages/calendar.dart';

import '../components/my_button.dart';
import '../components/my_textfield.dart';

// ignore: camel_case_types
class registerPage extends StatefulWidget {
  static const String id = 'register_page';
  const registerPage({super.key});

  @override
  State<registerPage> createState() => _registerPageState();
}

// ignore: camel_case_types
class _registerPageState extends State<registerPage> {
  final newstudentID = TextEditingController();
  final newemailController = TextEditingController();
  final newpasswordController = TextEditingController();
  final confirmpasswordController = TextEditingController();

  /// function to create new password for user
  ///
  void newuser(String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: newemailController.text, password: newpasswordController.text);
      Navigator.pushNamed(context, Calendar.id);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }

      /// logic for confirm password need to be placed
    } catch (e) {
      print(e);
    }
  }

  /// have to make function to send student id to firebase database

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color.fromARGB(255, 151, 53, 53)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),

            const Center(
                child: Text(
              "Register Page",
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            )),
            const SizedBox(
              height: 10,
            ),

            /// text fields to grab info
            const MyTextField(
              contoller: null,
              hinttext: "Student ID",
              obscureText: false,
            ),

            MyTextField(
              contoller: newemailController,
              hinttext: "Student Email",
              obscureText: false,
            ),

            MyTextField(
              contoller: newpasswordController,
              hinttext: "Password",
              obscureText: true,
            ),

            /// makes sure the user enters right password
            MyTextField(
              contoller: confirmpasswordController,
              hinttext: "Confirm Password",
              obscureText: true,
            ),

            const SizedBox(
              height: 30,
            ),

            // button to sign up
            MyButton(
              pressTap: () {
                newuser(newemailController.text, newpasswordController.text);
              },
              newtext: "Sign up",
            ),
          ],
        ),
      ),
    );
  }
}
