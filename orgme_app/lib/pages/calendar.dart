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
  TextEditingController eventController = TextEditingController();
  TextEditingController description = TextEditingController();
  //creating db object
  final isarService = IsarService();

  //Runs once when the screen is loaded.
  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    eventController.dispose();
    description.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    formattedMonth = returnMonth(selectedDay);
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("OrganizeMe", style: GoogleFonts.oswald(fontSize: 25)),
          centerTitle: true,
          backgroundColor: const Color(0xFF800000),
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
                                    if (eventController.text.isEmpty) {
                                    } else {
                                      //pull list of events from database
                                      var theList =
                                          await isarService.getEvents();
                                      //Testing to see if the existing events have the same name
                                      for (int i = 0; i < theList.length; i++) {
                                        if (eventController.text ==
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
                                              ..title = eventController.text
                                              ..desc = description.text
                                              ..date = formattedDay
                                              ..time = storedTime
                                              ..currentItem = '');
                                        isarService.saveEvent(Event()
                                          ..title = eventController.text
                                          ..desc = description.text
                                          ..date = formattedDay
                                          ..time = storedTime
                                          ..currentItem = '');
                                        //however if the map on the selected day is null, we
                                        //go ahead and give it a value, being the event
                                      } else {
                                        selectedEvents[formattedDay!] = [
                                          Event()
                                            ..title = eventController.text
                                            ..desc = description.text
                                            ..date = formattedDay
                                            ..time = storedTime
                                            ..currentItem = ''
                                        ];
                                        isarService.saveEvent(Event()
                                          ..title = eventController.text
                                          ..desc = description.text
                                          ..date = formattedDay
                                          ..time = storedTime
                                          ..currentItem = '');
                                      }
                                    }
                                    Navigator.pop(context);
                                    eventController.clear();
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
}
