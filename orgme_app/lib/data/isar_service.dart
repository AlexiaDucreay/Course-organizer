import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
import 'package:orgme_app/event.dart';
import 'package:orgme_app/pages/calendar.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<void> saveEvent(Event event) async {
    final isar = await db;
    isar.writeTxnSync<int>(() => isar.events.putSync(event));
  }

  Future<List<Event>> getEvents() async {
    final isar = await db;
    return isar.events.where().findAll();
    
  }

  Future<void> deleteEvents() async {
    final isar = await db;
    await isar.writeTxn(() => isar.clear());
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open([EventSchema], inspector: true);
    }

    return await Future.value(Isar.getInstance());
  }
}
