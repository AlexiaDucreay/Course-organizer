import 'package:flutter/material.dart';
import 'package:orgme_app/pages/calendar.dart';
import 'package:orgme_app/pages/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:orgme_app/pages/login_page.dart';
import 'package:orgme_app/pages/register.dart';
import 'package:orgme_app/pages/reset.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    // ignore: avoid_print, invalid_return_type_for_catch_error
  ).then((value) {}).catchError((err) => print(err));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Loginpage.id,
      routes: {
        Loginpage.id: (context) => const Loginpage(),
        AuthPage.id: (context) => const AuthPage(),
        registerPage.id: (context) => const registerPage(),
        resetPasswordPage.id: (context) => const resetPasswordPage(),
        Calendar.id: (context) => const Calendar(),
      },
    );
    // return const MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   home: AuthPage(),
    // );
  }
}
