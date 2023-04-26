import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
import 'package:orgme_app/event.dart';
import 'package:orgme_app/pages/calendar.dart';

//This class is responsible for running the database

class IsarService {
  late Future<Isar> db;
//opening the database when IsarService() is called and storing in a database object
  IsarService() {
    db = openDB();
  }
//method to save events to the database
  Future<void> saveEvent(Event event) async {
    final isar = await db;
    isar.writeTxnSync(() => isar.events.putSync(event));
  }

//method to grab all the events in the database
  Future<List<Event>> getEvents() async {
    final isar = await db;
    return isar.events.where().findAll();
  }

//method to delete all the events in the database
  Future<void> deleteEvents() async {
    final isar = await db;
    await isar.writeTxn(() => isar.clear());
  }

  Future<void> deleteEvent(Event event) async {
    final isar = await db;
    await isar.writeTxn(() => isar.events.filter().titleStartsWith(event.title!).deleteAll());
  }

//method that opens the database
  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open([EventSchema], inspector: true);
    }

    return await Future.value(Isar.getInstance());
  }
}
