import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'video_screen.dart' show VideoScreen;
import 'gym_screen.dart' show GymScreen;
import 'result_screen.dart';


void main() => runApp(FitnessApp());

class FitnessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'LeagueSpartan',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(userName: 'Norhene'),
        '/video': (context) => VideoScreen(),
        '/gym': (context) => GymScreen(),
        '/result': (context) => ResultScreen(),

      },
    );
  }
}
