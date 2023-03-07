import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orgme_app/weather.dart';
import 'package:orgme_app/weathermodel.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:orgme_app/event.dart';
import 'package:google_fonts/google_fonts.dart';

class Calendar extends StatefulWidget {
  static const String id = 'home_page';
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  Map<DateTime, List<Event>> selectedEvents = {};
  List items = [];
  CalendarFormat format = CalendarFormat.month;
  DateTime ?selectedDay;
  DateTime focusedDay = DateTime.now();
  WeatherService weatherService = WeatherService();
  Weather weather = Weather();
  int weatherCode = 0;
  String condition = "";
  double temp = 0.0;
  String theLocation = "";
  String coords = "";
  int counter = 0;
  int picNum = 113;
  TextEditingController eventController = TextEditingController();

  @override
  void initState() {
    selectedEvents = {};
    super.initState();
  }

  List<Event> getEvents(DateTime date) {
    return selectedEvents[date] ?? [];
  }

  @override
  void dispose() {
    eventController.dispose();
    super.dispose();
  }

  Future<void> readJson() async {
    final String response = await rootBundle.loadString("assets/codes.json");
    final data = await json.decode(response);
    setState(() {
      items = data["items"];
    });
  }

  void getWeather() async {
    weather = await weatherService.getWeatherData(coords);
    setState(() {
      temp = weather.temperature;
      condition = weather.condition;
      weatherCode = weather.code;
      theLocation = weather.location;
    });
  }

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
            ...getEvents(focusedDay).map((Event event) => ListTile(
                  title: Text(event.title),
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
                )), //onTap needs to go here.
            ElevatedButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text("Add Event"),
                            content: TextFormField(
                              controller: eventController,
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("Cancel")),
                              TextButton(
                                  onPressed: () {
                                    if (eventController.text.isEmpty) {
                                    } else {
                                      if (selectedEvents[focusedDay] != null) {
                                        selectedEvents[focusedDay]?.add(
                                            Event(title: eventController.text));
                                      } else {
                                        selectedEvents[focusedDay] = [
                                          Event(title: eventController.text)
                                        ];
                                      }
                                    }
                                    Navigator.pop(context);
                                    eventController.clear();
                                    setState(() {});
                                    return;
                                  },
                                  child: Text("Ok"))
                            ],
                          ));
                },
                child: const Icon(Icons.add)),
          ]),
        )));
  }
}