import 'dart:convert';
import 'package:orgme_app/weathermodel.dart';
import 'package:http/http.dart' as http;

//class that calls a weather api to grab weather
class WeatherService {
  Future<Weather> getWeatherData(String place) async {
    try {
      final params = {
        'key': '8d7fd2574bde4f40aac53219231802',
        'q': place,
      };
      final uri = Uri.http('api.weatherapi.com', '/v1/current.json', params);
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return Weather.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Can not get weather");
      }
    } catch (e) {
      rethrow;
    }
  }
}
