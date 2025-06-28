import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'video_screen.dart' show VideoScreen;
import 'gym_screen.dart' show GymScreen;
import 'result_screen.dart';

void main() => runApp(const FitnessApp());

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'LeagueSpartan',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(userName: 'Norhene'),
        '/video': (context) => const VideoScreen(),
        '/gym': (context) => const GymScreen(),
        '/result': (context) => const ResultScreen(),
      },
    );
  }
}
