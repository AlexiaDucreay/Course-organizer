// makes sure if the user can sign in
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orgme_app/pages/calendar.dart';
import 'package:orgme_app/pages/login_page.dart';

class AuthPage extends StatelessWidget {
  static const String id = 'auth_page';
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // user log in
          if (snapshot.hasData) {
            return const Calendar();
          }

          // user not log in
          else {
            return const Loginpage();
          }
        },
      ),
    );
  }
}
