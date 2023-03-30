import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orgme_app/components/my_button.dart';
import 'package:orgme_app/components/my_textfield.dart';
import 'package:flutter/src/material/time.dart';
import 'package:orgme_app/pages/calendar.dart';

class HomePage extends StatefulWidget {
  static const String id = 'event_page';
  const HomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool? isChecked = false;
  final title = TextEditingController();
  final description = TextEditingController();
  String valueChoose = '';
  List theItems = ["School", "General"];
  DateTime dateTime = DateTime(2023, 2, 3, 12, 0);
  DateTime dayTime = DateTime.now();
  String currentItemSelected = 'School';

  bool ifAutomate() {
    if (isChecked == false) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add an Event", style: GoogleFonts.oswald(fontSize: 25)),
        centerTitle: true,
        backgroundColor: Color(0xFF800000),
      ),
      body: Center(
          child: Container(
        child: SingleChildScrollView(
            child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Flexible(
                  child: Text(
                "Select Type of Event:",
                style: TextStyle(fontSize: 20),
              )),
              const SizedBox(width: 25),
              DropdownButton(
                items: theItems.map((dropdownString) {
                  return DropdownMenuItem(
                    value: dropdownString,
                    child: Text(dropdownString),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    currentItemSelected = newValue.toString();
                  });
                },
                value: currentItemSelected,
              ),
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Checkbox(
              activeColor: Color(0xFF800000),
                value: isChecked,
                onChanged: (newBool) {
                  setState(() {
                    isChecked = newBool;
                  });
                }),
            SizedBox(width: 2),
            Text(
              "Automate?",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(width: 15)
          ]),
          MyTextField(
              contoller: title, hinttext: "Title of event", obscureText: false),
          MyTextField(
              contoller: description,
              hinttext: "Description",
              obscureText: false),
          Visibility(
            visible: ifAutomate(),
            child: CupertinoButton(
              onPressed: () {
                showCupertinoModalPopup(
                    context: context,
                    builder: (BuildContext context) => SizedBox(
                          height: 250,
                          child: CupertinoDatePicker(
                              backgroundColor: Colors.white,
                              initialDateTime: dateTime,
                              onDateTimeChanged: (DateTime newTime) {
                                setState(() {
                                  dateTime = newTime;
                                });
                              }),
                        ));
              },
              child: Text(
                'Pick Time and Date',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              color: Color(0xFF800000),
            ),
          ),
          Visibility(
            visible: !ifAutomate(),
            child: CupertinoButton(
              onPressed: () {
                showCupertinoModalPopup(
                    context: context,
                    builder: (BuildContext context) => SizedBox(
                          height: 250,
                          child: CupertinoDatePicker(
                              backgroundColor: Colors.white,
                              initialDateTime: dateTime,
                              onDateTimeChanged: (DateTime newTime) {
                                setState(() {
                                  dayTime = newTime;
                                });
                              },
                              mode: CupertinoDatePickerMode.date),
                        ));
              },
              child: Text(
                'Pick Day',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              color: Color(0xFF800000),
            ),
          ),
          SizedBox(height: 100),
          CupertinoButton(
                onPressed: () {
                  Navigator.pushNamed(context, Calendar.id); //event page
                },
                child: Text("Enter"),
                color: Color(0xFF800000))
        ])),
      )),
    );
  }
}
