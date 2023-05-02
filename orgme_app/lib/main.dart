import 'package:flutter/material.dart';
import 'package:orgme_app/data/isar_service.dart';
import 'package:orgme_app/event.dart';
import 'package:orgme_app/pages/calendar.dart';
import 'package:orgme_app/pages/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:orgme_app/pages/file_upload.dart';
import 'package:orgme_app/pages/login_page.dart';
import 'package:orgme_app/pages/register.dart';
import 'package:orgme_app/pages/reset.dart';
import 'firebase_options.dart';
import 'data/isar_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    // ignore: avoid_print, invalid_return_type_for_catch_error
  ).then((value) {}).catchError((err) => print(err));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Loginpage.id,
      routes: {
        Loginpage.id: (context) => Loginpage(),
        AuthPage.id: (context) => AuthPage(),
        registerPage.id: (context) => registerPage(),
        resetPasswordPage.id: (context) => resetPasswordPage(),
        FileUploadPage.id: (context) => FileUploadPage(),
        Calendar.id: (context) => Calendar(),
      },
    );
    // return const MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   home: AuthPage(),
    // );
  }
}
