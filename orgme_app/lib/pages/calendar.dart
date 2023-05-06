// Blake Gauna

// Calendar (Home) Page

// Future<void> readJson() async - This function loads the .json file located in the assets folder
// and decodes the json file into an array of objects. This file contains custom weather 
// codes and custom messages.

// Future<void> getLocation() async - This function first asks the user for permission to grab their
// location. Once the system has permission, it grabs the coordinates of the user.

// Future<void> getWeather() async - This function passes the coordinates into a weather api and
// grabs the temperature, city name, and weather code that will be used in getIcon().

// Future<void> getIcon() async - This goes through the list of .json objects in the array and based
// on the weather code retrieved from the weather api, grabs the corresponding icon and 
// custom weather message.

// void pull() async - This function runs once when initState is called. initState is
// called once when the page is loaded, so all the methods are called and the selecedEvents
// map is filled with the necessary information.

// List<Event> getEvents - getEvents returns the events from the selectedEvents map, otherwise it
// returns an empty list. getEvents is specifically used with the TableCalendar widget.

// 

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:orgme_app/data/isar_service.dart';
import 'package:orgme_app/pages/login_page.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:orgme_app/event.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:orgme_app/weather.dart';
import 'package:orgme_app/weathermodel.dart';

import 'file_upload.dart';

class Calendar extends StatefulWidget {
  static const String id = 'home_page';
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  //map to store events in with the key being the date
  Map<DateTime, List<Event>> selectedEvents = {};
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  DateTime? formattedDay;
  TimeOfDay time = const TimeOfDay(hour: 12, minute: 0);
  DateTime? storedTime;
  DateTime? day;
  String formattedMonth = '';
  CalendarFormat format = CalendarFormat.month;
  bool automate = false;
  String hourMinute = '';
  //controllers to get text input
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  //creating db object
  final isarService = IsarService();
  //Array of results pulled from the database
  var theResults;
  //List of items that are in JSON format pulled from the assets folder.
  //List of possible weathers with custom weather codes and icons.
  List items = [];
  String condition = "";
  double temp = 0.0;
  String theLocation = "";
  String coords = "";
  WeatherService weatherService = WeatherService();
  Weather weather = Weather();
  int weatherCode = 0;
  int counter = 0;
  int picNum = 113;

  //Runs once when the screen is loaded.
  @override
  void initState() {
    super.initState();
    pull();
    
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

// void pull() async - This function runs once when initState is called. initState is
// called once when the page is loaded, so all the methods are called and the selecedEvents
// map is filled with the necessary information.
  void pull() async {
    theResults = await isarService.getEvents();
    await readJson();
    await getLocation();
    await getWeather();
    await getIcon();
    //Loops through the events pulled from the database and stores them in a map.
    //Map loops like <DateTime, List<Event>>, so the date will
    //be the key and the list of events will be the value.
    //This map is used to store events in the calendar.
    for (int i = 0; i < theResults.length; i++) {
      //If the day has events in it, add the event to the end of the list.
      if (selectedEvents[theResults[i].date] != null) {
        selectedEvents[theResults[i].date!]?.add(Event()
          ..title = theResults[i].title
          ..desc = theResults[i].desc
          ..date = theResults[i].date
          ..time = theResults[i].time
          ..currentItem = theResults[i].currentItem);
        //Else, the day doesn't have events in it, so we just make the
        //value equal to the event
      } else {
        selectedEvents[theResults[i].date!] = [
          Event()
            ..title = theResults[i].title
            ..desc = theResults[i].desc
            ..date = theResults[i].date
            ..time = theResults[i].time
            ..currentItem = theResults[i].currentItem
        ];
      }
    }
  }


// Future<void> readJson() async - This function loads the .json file located in the assets folder
// and decodes the json file into an array of objects. This file contains custom weather 
// codes and custom messages.
  Future<void> readJson() async {
    final String response = await rootBundle.loadString("assets/codes.json");
    final data = await json.decode(response);
    setState(() {
      items = data["items"];
    });
  }

// Future<void> getWeather() async - This function passes the coordinates into a weather api and
// grabs the temperature, city name, and weather code that will be used in getIcon().
  Future<void> getWeather() async {
    weather = await weatherService.getWeatherData(coords);
    setState(() {
      temp = weather.temperature;
      condition = weather.condition;
      weatherCode = weather.code;
      theLocation = weather.location;
    });
  }

// Future<void> getLocation() async - This function first asks the user for permission to grab their
// location. Once the system has permission, it grabs the coordinates of the user.
  Future<void> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
    String lat = position.latitude.toString();
    String lon = position.longitude.toString();
    coords = "$lat,$lon";
  }

// Future<void> getIcon() async - This goes through the list of .json objects in the array and based
// on the weather code retrieved from the weather api, grabs the corresponding icon and 
// custom weather message.
  Future<void> getIcon() async {
    counter = 0;
    if (weatherCode != 0) {
      while (items[counter]["code"] != weatherCode) {
        counter++;
      }
      picNum = await items[counter]["icon"];
    }
    return;
  }

  //returns a list of events for a given day
  List<Event> getEvents(DateTime date) {
    int day = date.day;
    int month = date.month;
    int year = date.year;
    formattedDay = DateTime(year, month, day);
    //return the list of events at the given day, or if its null, return an empty list
    return selectedEvents[formattedDay] ?? [];
  }

  //datetime to month string converter
  String returnMonth(DateTime date) {
    return DateFormat.MMMM().format(date);
  }

// Returns a list of events for the selected month.
  List<Event> getEventsForSelectedMonth() {
    final eventsForSelectedMonth = <Event>[];
    for (final date in selectedEvents.keys) {
      if (date.month == selectedDay.month && date.year == selectedDay.year) {
        eventsForSelectedMonth.addAll(selectedEvents[date]!);
      }
    }
    return eventsForSelectedMonth;
  }

  // Generates a PDF document of events and returns it as a byte array.
  FutureOr<Uint8List> generatePdf(List<Event> events) async {
    final font = await rootBundle.load("assets/fonts/OpenSans-Regular.ttf");
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Center(
            // array to display the events by date, time, title, description
            child: pw.Table.fromTextArray(
              data: [
                ['Date', 'Time', 'Title', 'Description'],
                ...events.map((event) => [
                      DateFormat.yMd().format(event.date!),
                      event.time != null ? formatTime(event.time!) : '',
                      event.title,
                      event.desc,
                    ])
              ],
              headerStyle: pw.TextStyle(
                font: pw.Font.ttf(font),
                fontWeight: pw.FontWeight.bold,
              ),
              border: pw.TableBorder.all(),
              cellAlignment: pw.Alignment.center,
            ),
          );
        },
      ),
    );
    return pdf.save();
  }

  /// format the time to display like the calendar
  String formatTime(DateTime dateTime) {
    final TimeOfDay timeOfDay = TimeOfDay.fromDateTime(dateTime);
    return timeOfDay.format(context);
  }

  //Method to set our time variable equal to what the user picks.
  Future<void> selectTime() async {
    TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: time);
    if (picked != null) {
      setState(() {
        time = picked;
        storedTime = DateTime(2023, 1, 1, time.hour, time.minute);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    formattedMonth = returnMonth(selectedDay);
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("OrganizeMe", style: GoogleFonts.oswald(fontSize: 25)),
          centerTitle: true,
          backgroundColor: const Color(0xFF800000),
          actions: <Widget>[
            PopupMenuButton(
              itemBuilder: (BuildContext popupContext) {
                final currentUser = FirebaseAuth.instance.currentUser;
                return [
                  // Display a message showing the email of the current user
                  PopupMenuItem(
                    // ignore: sort_child_properties_last
                    child:
                        // shows what user is logged in with firebase auth
                        Text('Logged in as ${currentUser?.email ?? "Unknown"}'),
                    enabled: false,
                  ),
                  // Sign out the current user and navigate to the login page
                  PopupMenuItem(
                    child: const Text('Sign Out'),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      // ignore: use_build_context_synchronously
                      Navigator.pushNamed(
                        popupContext,
                        Loginpage.id,
                      );
                    },
                  ),
                  //pushes you to pdf page
                  PopupMenuItem(
                    child: const Text('Upload file'),
                    onTap: () {
                      print("hello");
                      Navigator.pushNamed(context, FileUploadPage.id);
                    },
                  ),
                  //button to print the events
                  PopupMenuItem(
                    child: const Text('Print events'),
                    onTap: () async {
                      // gets functions to print the events
                      // if there is no events prints noting
                      final eventsForSelectedMonth =
                          getEventsForSelectedMonth();
                      if (eventsForSelectedMonth.isNotEmpty) {
                        await Printing.layoutPdf(
                          onLayout: (format) =>
                              generatePdf(eventsForSelectedMonth),
                        );
                      }
                    },
                  )
                ];
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              //Row of widgets to display the weather
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Image.asset('assets/day/$picNum.png'),
                  const SizedBox(width: 15),
                  Flexible(
                    child: Text(" $temp °F \t $theLocation \n " "$condition",
                        style: GoogleFonts.oswald(fontSize: 22)),
                  )
                ],
              ),
            ),
            //Table Calendar widget
            TableCalendar(
              focusedDay: focusedDay,
              firstDay: DateTime(2000),
              lastDay: DateTime(2030),
              calendarFormat: format,
              onFormatChanged: (CalendarFormat theFormat) {
                setState(() {
                  format = theFormat;
                });
              },
              onPageChanged: (focusDay) {
                focusedDay = focusDay;
              },
              onDaySelected: (DateTime theSelectedDay, DateTime focusDay) {
                if (!isSameDay(theSelectedDay, selectedDay)) {
                  // Call `setState()` when updating the selected day
                  setState(() {
                    selectedDay = theSelectedDay;
                    focusedDay = focusDay;
                    formattedMonth = returnMonth(selectedDay);
                  });
                }
                // setState(() {
                //   selectedDay = selectDay;
                //   focusedDay = focusDay;
                // });
              },
              selectedDayPredicate: (DateTime date) {
                return isSameDay(selectedDay, date);
              },
              eventLoader: getEvents,
              //styling
              calendarStyle: const CalendarStyle(
                  isTodayHighlighted: true,
                  selectedDecoration: BoxDecoration(
                      color: Color(0xFF800000), shape: BoxShape.circle),
                  selectedTextStyle: TextStyle(color: Colors.white),
                  todayDecoration: BoxDecoration(
                      color: Color(0xFFa52a2a), shape: BoxShape.circle)),
              headerStyle: const HeaderStyle(
                  formatButtonShowsNext: false, titleCentered: true),
            ),
            //appending list tiles to the bottom of the container if
            //there are valid days in the map
            ...getEvents(selectedDay).map((Event event) => ListTile(
                  title: Text(event.title.toString()),
                  subtitle: Text(event.desc.toString()),
                  //This is where the event times will be
                  //DateFormat('jm') returns the formatted time
                  trailing: Text(DateFormat('jm').format(event.time!)),
                  //Time constraint on editing events
                  onTap: () {},
                  onLongPress: () {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: const Text("Delete Event"),
                              content: const Text(
                                  "Are you sure you want to delete this event?"),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancel")),
                                TextButton(
                                    onPressed: () {
                                      int day = selectedDay.day;
                                      int month = selectedDay.month;
                                      int year = selectedDay.year;
                                      formattedDay = DateTime(year, month, day);
                                      selectedEvents[formattedDay]?.removeWhere(
                                          (element) =>
                                              element.title == event.title);
                                      isarService.deleteEvent(event);
                                      setState(() {});
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Ok"))
                              ],
                            ));
                  },
                )),
            const SizedBox(height: 25),
            //This button is responsible for adding events to the database and the calendar
            ElevatedButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => StatefulBuilder(
                          //    if want to add back, v  <= setState goes by context (context, setState)
                          builder: (context, setState) => AlertDialog(
                            title: const Text("Add Event"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  controller: title,
                                  decoration: const InputDecoration(
                                      hintText: "Name of Event"),
                                ),
                                TextFormField(
                                  controller: description,
                                  decoration: const InputDecoration(
                                      hintText: "Description"),
                                ),
                                const SizedBox(height: 15),
                                Text(
                                    "Selected Day: $formattedMonth, ${selectedDay.day}, ${selectedDay.year}"),
                                const SizedBox(height: 10),
                                CheckboxListTile(
                                    title: const Text("Automate?"),
                                    value: automate,
                                    onChanged: (newValue) {
                                      setState(() {
                                        automate = newValue!;
                                        int day = selectedDay.day;
                                        int month = selectedDay.month;
                                        int year = selectedDay.year;
                                        formattedDay =
                                            DateTime(year, month, day);
                                        if (selectedEvents[formattedDay] !=
                                            null) {
                                          Event? temp = selectedEvents[
                                                  formattedDay]
                                              ?.elementAt(
                                                  selectedEvents[formattedDay]!
                                                          .length -
                                                      1);
                                          int hour = temp!.time!.hour;
                                          if (hour++ > 23) {
                                            hour = 0;
                                          } else {
                                            hour++;
                                            DateTime tempTime = DateTime(
                                                year, month, day, hour);
                                            storedTime = tempTime;
                                          }
                                        } else {
                                          int day = selectedDay.day;
                                          int month = selectedDay.month;
                                          int year = selectedDay.year;
                                          int hour = 12;
                                          DateTime tempTime =
                                              DateTime(year, month, day, hour);
                                          storedTime = tempTime;
                                        }
                                      });
                                    }),
                                Visibility(
                                  visible: !automate,
                                  child: ElevatedButton(
                                    //  ElevatedButton(
                                    onPressed: () async {
                                      selectTime();
                                    },
                                    child: const Text("Select Time"),
                                  ),
                                )
                              ],
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cancel")),
                              TextButton(
                                  onPressed: () async {
                                    //Logic to add events to the map
                                    //if the text field is empty, ignore
                                    if (title.text.isEmpty) {
                                    } else {
                                      //pull list of events from database
                                      var theList =
                                          await isarService.getEvents();
                                      //Testing to see if the existing events have the same name
                                      for (int i = 0; i < theList.length; i++) {
                                        if (title.text ==
                                            theList[i].title) {
                                          showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                    title: const Text(
                                                        "Duplicate Name"),
                                                    content: const Text(
                                                        "Cannot have duplicate names with other events."),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child:
                                                              const Text("Ok"))
                                                    ],
                                                  ));
                                          return;
                                        }
                                      }
                                      int day = selectedDay.day;
                                      int month = selectedDay.month;
                                      int year = selectedDay.year;
                                      formattedDay = DateTime(year, month, day);
                                      //else, if the map on the selected day is not null, append
                                      //the event to the end of the list
                                      if (selectedEvents[formattedDay] !=
                                          null) {
                                        selectedEvents[formattedDay]
                                            ?.add(Event()
                                              ..title = title.text
                                              ..desc = description.text
                                              ..date = formattedDay
                                              ..time = storedTime
                                              ..currentItem = '');
                                        isarService.saveEvent(Event()
                                          ..title = title.text
                                          ..desc = description.text
                                          ..date = formattedDay
                                          ..time = storedTime
                                          ..currentItem = '');
                                        //however if the map on the selected day is null, we
                                        //go ahead and give it a value, being the event
                                      } else {
                                        selectedEvents[formattedDay!] = [
                                          Event()
                                            ..title = title.text
                                            ..desc = description.text
                                            ..date = formattedDay
                                            ..time = storedTime
                                            ..currentItem = ''
                                        ];
                                        isarService.saveEvent(Event()
                                          ..title = title.text
                                          ..desc = description.text
                                          ..date = formattedDay
                                          ..time = storedTime
                                          ..currentItem = '');
                                      }
                                    }
                                    Navigator.pop(context);
                                    title.clear();
                                    description.clear();
                                    automate = false;
                                    setState(() {});
                                    //return;
                                  },
                                  child: const Text("Ok"))
                            ],
                          ),
                        )).then((_) => setState(() {}));
                //Updates the screen after the dialog disappears.
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF800000)),
              child: const Icon(Icons.add),
            ),
            //this button deletes all of the events from the database
            ElevatedButton(
                onPressed: () {
                  selectedEvents.clear();
                  isarService.deleteEvents();
                  setState(() {});
                },
                child: const Text("Delete all"))

            //this button is used to load in the objects from the database
          ]),
        ));
  }


}