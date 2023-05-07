// Edgar Zapata
// Auth page  is used for firebase to check if the user is in the firebase database
// This is to allow the user to be signed in if not it will not login in the user
// firebaseauth.instance is where all the checking is looked at

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orgme_app/pages/calendar.dart';
import 'package:orgme_app/pages/login_page.dart';

class AuthPage extends StatelessWidget {
  // A unique identifier for this page
  static const String id = 'auth_page';

  // Constructor for this page
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold is a basic screen structure widget that provides a default app bar, body, and more
    return Scaffold(
      // StreamBuilder is a widget that listens for changes in the stream and rebuilds its child widget
      // whenever the data changes
      body: StreamBuilder<User?>(
        // authStateChanges() returns a Stream<User?> which emits events whenever the authentication state
        // changes, so the stream will emit an event whenever a user signs in or signs out
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // If the user is logged in, show the calendar page
          if (snapshot.hasData) {
            // The const keyword is used to create a compile-time constant value, which can improve
            // performance and reduce memory usage
            return const Calendar();
          }

          // If the user is not logged in, show the login page
          else {
            return const Loginpage();
          }
        },
      ),
    );
  }
}
