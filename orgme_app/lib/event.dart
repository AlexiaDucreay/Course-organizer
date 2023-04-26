import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'event.g.dart';

@Collection()
class Event {
  Id id = Isar.autoIncrement;
  String? title;
  String? desc;
  DateTime? date;
  DateTime? time;
  String? currentItem;
}
