//Edgar Zapta
// reset password page
// class: reset password page state, resetpassword function, to
// use firebase auth to check if the email already exist
// and allow the user to be sent an email to  reset the password

// ignore_for_file: avoid_print, duplicate_ignore
// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';

// ignore: camel_case_types
class resetPasswordPage extends StatefulWidget {
  static const String id = 'reset_page';
  const resetPasswordPage({super.key});

  @override
  State<resetPasswordPage> createState() => _resetPasswordPageState();
}

// ignore: camel_case_types
// class to rest password for register user
class _resetPasswordPageState extends State<resetPasswordPage> {
  final emailAddressController = TextEditingController();

  /// get user email
  /// popups a box to show a email reset for user
  Future<void> resetPassword({required String email}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailAddressController.text,
      );

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset email sent',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          e.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        )),
      );
    }
  }

  // page build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color.fromARGB(255, 151, 53, 53)),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 80, 0, 0),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 50,
              ),
              const Center(
                  child: Text(
                "Reset Your Password",
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              )),
              const SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    ' Enter your email \n \nwe will send a link to reset your password.',
                    style: TextStyle(fontSize: 15, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              MyTextField(
                contoller: emailAddressController,
                hinttext: "Email",
                obscureText: false,
              ),
              MyButton(
                pressTap: () async {
                  resetPassword(email: emailAddressController.text);
                },
                newtext: "reset password",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
