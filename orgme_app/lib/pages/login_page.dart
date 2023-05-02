import 'dart:convert';
import 'package:orgme_app/weather.dart';
import 'package:orgme_app/weathermodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orgme_app/components/my_textfield.dart';
import 'package:orgme_app/data/isar_service.dart';
import 'package:orgme_app/pages/calendar.dart';
import 'package:orgme_app/pages/register.dart';
import 'package:orgme_app/pages/reset.dart';
import '../components/my_button.dart';
import '../event.dart';
import 'package:geolocator/geolocator.dart';

//Global variables because they are loaded in a page early to instantly display data
//on the next page when user has logged in.
//Ma
var theResults;
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

class Loginpage extends StatefulWidget {
  static const String id = 'login_page';
  final Function()? onTap;
  const Loginpage({super.key, this.onTap});

  //const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

//class for sign in user
class _LoginpageState extends State<Loginpage> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isarService = IsarService();

  //function to sign in user
  Future signuserIn() async {
    // calls firebase auth to make sure user is in firebase
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      Navigator.pushNamed(context, Calendar.id);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        wrongEmailMessage();
      } else if (e.code == 'wrong-password') {
        wrongPasswordMessage();
      }
    }
  }

  /// wrong email and password function
  /// pops up a message when user input wrong email or password

  void wrongEmailMessage() {
    showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text('Incorrect Email'),
          );
        });
  }

  void wrongPasswordMessage() {
    showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text('Incorrect Password'),
          );
        });
  }
  // dispose of the controllers after signing  in user

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    pull();
  }

  void pull() async {
    theResults = await isarService.getEvents();
    await readJson();
    await getLocation();
    await getWeather();
    await getIcon();
  }

  Future<void> readJson() async {
    final String response = await rootBundle.loadString("assets/codes.json");
    final data = await json.decode(response);
    setState(() {
      items = data["items"];
    });
  }

  Future<void> getWeather() async {
    weather = await weatherService.getWeatherData(coords);
    setState(() {
      temp = weather.temperature;
      condition = weather.condition;
      weatherCode = weather.code;
      theLocation = weather.location;
    });
  }

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

  @override
  Widget build(BuildContext context) {
    // readJson();
    // getLocation();
    // getWeather();
    // getIcon();
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 151, 53, 53),
      // ignore: prefer_const_literals_to_create_immutables
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: SafeArea(
            child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'lib/images/msu.png',
                      width: 200,
                      height: 200,
                    ),

                    // Icon(
                    //   //logo
                    //   Icons.lock,
                    //   size: 100,
                    // ),

                    //Welcome back!
                    const Text(
                      'Welcome back!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),

                    // email
                    MyTextField(
                      contoller: emailController,
                      hinttext: "Email",
                      obscureText: false,
                    ),

                    const SizedBox(height: 2),
                    //password
                    MyTextField(
                      contoller: passwordController,
                      hinttext: "Password",
                      obscureText: true,
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.00),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, resetPasswordPage.id);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
                            Text(
                              'Forgot password?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // sign in button
                    const SizedBox(height: 10),

                    MyButton(
                      pressTap: () async {
                        signuserIn();
                      },
                      newtext: "Sign in",
                    ),

                    const SizedBox(height: 3),

                    // not a member? register now
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Not a member?',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 4),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, registerPage.id);
                          },
                          child: const Text(
                            'Register now',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    )
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
