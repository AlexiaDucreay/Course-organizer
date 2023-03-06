// ignore_for_file: avoid_print, duplicate_ignore

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orgme_app/pages/login_page.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // MyButton(
          //   pressTap: () async {
          //     try {
          //       await FirebaseAuth.instance.signOut();
          //       Navigator.of(context)
          //           .push(MaterialPageRoute(builder: (context) => Loginpage()));
          //     } on FirebaseAuthException catch (e) {
          //       print('Failed with error code: ${e.code}');
          //       print(e.message);
          //     }
          //   },
          //   color: Colors.red,
          //   newtext: "Sign out",
          // ),

          AppBar(
            actions: [
              IconButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signOut();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const Loginpage()));
                  } on FirebaseAuthException catch (e) {
                    // ignore: avoid_print
                    print('Failed with error code: ${e.code}');
                    print(e.message);
                  }
                },
                icon: const Icon(Icons.logout),
              )
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          const Center(child: Text("TESTTTETETTETET")),
        ],
      ),
    );
  }
}
