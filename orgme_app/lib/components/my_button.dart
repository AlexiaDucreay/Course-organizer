import 'package:flutter/material.dart';

// class to call a button for any dart file that need one
class MyButton extends StatelessWidget {
  // final Function()? onTap;
  final VoidCallback pressTap;
  final Color color;
  final String newtext;
  const MyButton(
      {super.key,
      this.newtext = 'default',
      required this.pressTap,
      this.color = Colors.black});

  /// button layout
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: pressTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
            child: Text(newtext,
                style: const TextStyle(
                  color: Colors.white,
                ))),
      ),
    );
  }
}
