// makes sure if the user can sign in
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orgme_app/pages/login_page.dart';

import 'home_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // user log in
          if (snapshot.hasData) {
            return const Homepage();
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
