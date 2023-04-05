import 'package:flutter/material.dart';

//class that holds a weather object
//decodes a json object
class Weather {
  final double temperature;
  final String condition;
  final int code;
  final String location;

  Weather({this.temperature = 0, this.condition = "", this.code = 0, this.location = ""});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      temperature: json['current']['temp_f'],
      condition: json['current']['condition']['text'],
      code: json['current']['condition']['code'],
      location: json['location']['name']
    );
  }
}
