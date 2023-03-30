import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orgme_app/components/my_textfield.dart';
import 'package:orgme_app/pages/calendar.dart';
import 'package:orgme_app/pages/register.dart';
import 'package:orgme_app/pages/reset.dart';

import '../components/my_button.dart';

class Loginpage extends StatefulWidget {
  static const String id = 'login_page';
  final Function()? onTap;
  const Loginpage({super.key, this.onTap});

  //const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  // text editing controllers
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  //sign user in
  Future signuserIn() async {
    /// show login circle
    // showDialog(
    //     context: context,
    //     builder: (context) {
    //       return const Center(
    //         child: CircularProgressIndicator(),
    //       );
    //     });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      Navigator.pushNamed(context, Calendar.id);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        /// Navigator.pop((context));
        wrongEmailMessage();
      } else if (e.code == 'wrong-password') {
        // Navigator.pop((context));
        wrongPasswordMessage();
      }
    }

    /// pop the circle off once user logins in
  }

  /// wrong email and password message

  void wrongEmailMessage() {
    showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text('Incorrect Email'),
          );
        });
  }

  void wrongPasswordMessage() {
    showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text('Incorrect Password'),
          );
        });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 151, 53, 53),
      // ignore: prefer_const_literals_to_create_immutables
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: SafeArea(
            child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'lib/images/msu.png',
                      width: 200,
                      height: 200,
                    ),

                    // Icon(
                    //   //logo
                    //   Icons.lock,
                    //   size: 100,
                    // ),

                    //Welcome back!
                    const Text(
                      'Welcome back!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),

                    // email
                    MyTextField(
                      contoller: emailController,
                      hinttext: "Email",
                      obscureText: false,
                    ),

                    const SizedBox(height: 2),
                    //password
                    MyTextField(
                      contoller: passwordController,
                      hinttext: "Password",
                      obscureText: true,
                    ),

                    // //forgot password?
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 25.00),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.end,
                    //     children: const [
                    //       Text(
                    //         'Forgot password?',
                    //         style: TextStyle(
                    //           color: Colors.white,
                    //           fontSize: 15,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.00),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, resetPasswordPage.id);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
                            Text(
                              'Forgot password?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // sign in button
                    const SizedBox(height: 10),

                    MyButton(
                      pressTap: () async {
                        signuserIn();
                      },
                      newtext: "Sign in",
                    ),

                    const SizedBox(height: 3),

                    // not a member? register now
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Not a member?',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 4),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, registerPage.id);
                          },
                          child: const Text(
                            'Register now',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    )
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
