//Edgar Zapta
//register page is used to make the new user a login and account
//class registerpage uses newuser, weakpassword, email in use
// new user is using firebase auth to make sure that the user is not already in the
// database or if the password is weak
// after all this the text controllers are disposed for security purposes
// ignore_for_file: avoid_print, duplicate_ignore
// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orgme_app/pages/calendar.dart';

import '../components/my_button.dart';
import '../components/my_textfield.dart';

// ignore: camel_case_types
// This widget represents the Register Page
class registerPage extends StatefulWidget {
  static const String id = 'register_page';
  const registerPage({super.key});

  @override
  State<registerPage> createState() => _registerPageState();
}

// ignore: camel_case_types
class _registerPageState extends State<registerPage> {
  // Controllers for the email and password fields
  final newemailController = TextEditingController();
  final newpasswordController = TextEditingController();
  final confirmpasswordController = TextEditingController();

  /// function to create new password for user
  void newuser(String email, String password) async {
    try {
      // Create the user account with Firebase Auth
      // Navigate to the Calendar page if successful
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: newemailController.text, password: newpasswordController.text);
      Navigator.pushNamed(context, Calendar.id);
      // Handle specific exceptions thrown by Firebase Auth
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        weakpassword();
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        emailExist();
      }

      // Logic for confirming the password needs to be added here
    } catch (e) {
      // Handle other exceptions that may occur
      print(e);
    }
  }

// Function to display a dialog box indicating that the password is weak
  void weakpassword() {
    showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text('Weak password. 6 or more characters'),
          );
        });
  }

  // Function to display a dialog box indicating that the email is already in use
  void emailExist() {
    showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text('Email is already in use'),
          );
        });
  }

  // Dispose of the email and password controllers when the widget is disposed
  @override
  void dispose() {
    newemailController.dispose();
    newpasswordController.dispose();
    super.dispose();
  }

  // Build the UI for the Register Page
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
