import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:orgme_app/data/date_time.dart';
import 'package:orgme_app/data/isar_service.dart';
import 'package:orgme_app/weather.dart';
import 'package:orgme_app/weathermodel.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:orgme_app/event.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';


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
  TimeOfDay time = const TimeOfDay(hour: 12, minute: 0);
  DateTime? day;
  String formattedMonth = '';
  List items = [];
  CalendarFormat format = CalendarFormat.month;
  WeatherService weatherService = WeatherService();
  Weather weather = Weather();
  int weatherCode = 0;
  String condition = "";
  double temp = 0.0;
  String theLocation = "";
  String coords = "";
  int counter = 0;
  int picNum = 113;
  //controllers to get text input
  TextEditingController eventController = TextEditingController();
  TextEditingController description = TextEditingController();
  //creating db object
  final isarService = IsarService();

  @override
  void initState() {
    super.initState();
    // selectedEvents.forEach((key, value) {
    //   print(value[0].title);
    // });
  }
  // in progress function
  // void pullEvents() async {
  // var results = await isarService.getEvents();
  // for (int i = 0; i < results.length; i++) {
  //   if (selectedEvents[results[i].date] != null) {
  //     selectedEvents[results[i].date!]?.add(Event()
  //       ..title = results[i].title
  //       ..desc = results[i].desc
  //       ..date = results[i].date
  //       ..currentItem = results[i].currentItem);
  //   } else {
  //     selectedEvents[results[i].date!] = [
  //       Event()
  //         ..title = results[i].title
  //         ..desc = results[i].desc
  //         ..date = results[i].date
  //         ..currentItem = results[i].currentItem
  //     ];
  //   }
  // }
  //   setState(() {});
  //   selectedEvents.forEach((key, value) {
  //     print(value[0].title);
  //   });
  // }

  @override
  void dispose() {
    eventController.dispose();
    description.dispose();
    super.dispose();
  }
  //returns a list of events for a given day
  List<Event> getEvents(DateTime date) {
    return selectedEvents[date] ?? [];
  }
  //datetime to month string converter
  String returnMonth(DateTime date) {
    return DateFormat.MMMM().format(date);
  }
  //function to read json file with weather codes and weather messages
  Future<void> readJson() async {
    final String response = await rootBundle.loadString("assets/codes.json");
    final data = await json.decode(response);
    setState(() {
      items = data["items"];
    });
  }
  //gets weather based on location, and displays it accordingly
  void getWeather() async {
    weather = await weatherService.getWeatherData(coords);
    setState(() {
      temp = weather.temperature;
      condition = weather.condition;
      weatherCode = weather.code;
      theLocation = weather.location;
    });
  }
  //must get the users location to display weather
  //logic to ask the user to share location permissions
  void getLocation() async {
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
  //get the weather icon from file
  void getIcon() async {
    counter = 0;
    if (weatherCode != 0) {
      while (items[counter]["code"] != weatherCode) {
        counter++;
      }
      picNum = await items[counter]["icon"];
    } else {
      print("The weather code is not valid");
    }
  }

  @override
  Widget build(BuildContext context) {
    readJson();
    getLocation();
    getWeather();
    getIcon();
    formattedMonth = returnMonth(selectedDay);
    return Scaffold(
        appBar: AppBar(
          title: Text("OrganizeMe", style: GoogleFonts.oswald(fontSize: 25)),
          centerTitle: true,
          backgroundColor: Color(0xFF800000),
        ),
        body: Container(
            child: SingleChildScrollView(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              //Row of widgets to display the weather
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    child: Image.asset('assets/day/$picNum.png'),
                  ),
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<Widget>(
                          builder: (BuildContext context) {
                        return Scaffold(
                          appBar: AppBar(title: const Text('ListTile Hero')),
                          body: Center(
                            child: Hero(
                              tag: 'ListTile-Hero',
                              child: Material(
                                child: ListTile(
                                  title: const Text('ListTile with Hero'),
                                  subtitle: const Text('Tap here to go back'),
                                  tileColor: Color(0xFF800000),
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                )),
            SizedBox(height: 25),
            //This button is responsible for adding events to the database and the calendar
            ElevatedButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: Text("Add Event"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                controller: eventController,
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
                                  "Selected Day: ${formattedMonth}, ${selectedDay.day}, ${selectedDay.year}"),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () async {
                                  selectTime();
                                },
                                child: const Text("Select Time"),
                              )
                            ],
                          ),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Cancel")),
                            TextButton(
                                onPressed: () {
                                  //Logic to add events to the map
                                  //if the text field is empty, ignore
                                  if (eventController.text.isEmpty) {
                                  } else {
                                    //else, if the map on the selected day is not null, append
                                    //the event to the end of the list
                                    if (selectedEvents[selectedDay] != null) {
                                      selectedEvents[selectedDay]?.add(Event()
                                        ..title = eventController.text
                                        ..desc = description.text
                                        ..date = selectedDay
                                        ..currentItem = '');
                                      isarService.saveEvent(Event()
                                        ..title = eventController.text
                                        ..desc = description.text
                                        ..date = selectedDay
                                        ..currentItem = '');
                                      //however if the map on the selected day is null, we
                                      //go ahead and give it a value, being the event
                                    } else {
                                      selectedEvents[selectedDay] = [
                                        Event()
                                          ..title = eventController.text
                                          ..desc = description.text
                                          ..date = selectedDay
                                          ..currentItem = ''
                                      ];
                                      isarService.saveEvent(Event()
                                        ..title = eventController.text
                                        ..desc = description.text
                                        ..date = selectedDay
                                        ..currentItem = '');
                                    }
                                  }
                                  Navigator.pop(context);
                                  eventController.clear();
                                  description.clear();
                                  setState(() {});
                                  return;
                                },
                                child: Text("Ok"))
                          ],
                        ));
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: Color(0xFF800000)),
              child: const Icon(Icons.add),
            ),
            //this button deletes all of the events from the database
            ElevatedButton(
                onPressed: () {
                  isarService.deleteEvents();
                },
                child: Text("Delete all")),
            //IN PROGRESS, ON THE BRINK OF A BREAKTHROUGH
            //this button is used to load in the objects from the database
            ElevatedButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text("Load Events?"),
                            content: Text("Do you want to load the events?"),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("Cancel")),
                              TextButton(
                                  //if the okay button is hit, we grab the objects from the database
                                  //then we loop through the list of events and set them in their
                                  //appropriate place given the date.
                                  onPressed: () async {
                                    var results = await isarService.getEvents();
                                    for (int i = 0; i < results.length; i++) {
                                      selectedDay = results[i].date!;
                                      if (selectedEvents[selectedDay] != null) {
                                        selectedEvents[selectedDay]?.add(Event()
                                          ..title = results[i].title
                                          ..desc = results[i].desc
                                          ..date = selectedDay
                                          ..currentItem = '');
                                      } else {
                                        selectedEvents[selectedDay] = [
                                          Event()
                                            ..title = results[i].title
                                            ..desc = results[i].desc
                                            ..date = selectedDay
                                            ..currentItem = ''
                                        ];
                                      }
                                    }
                                    Navigator.pop(context);
                                    setState(() {});
                                    return;
                                  },
                                  child: Text("Ok"))
                            ],
                          ));
                },
                child: Text("Load Events"))
          ]),
        )));
  }
//Method to set our time variable equal to what the user picks.
  Future<void> selectTime() async {
    TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: time);
    if (picked != null) {
      setState(() {
        time = picked;
      });
    }
  }
}
