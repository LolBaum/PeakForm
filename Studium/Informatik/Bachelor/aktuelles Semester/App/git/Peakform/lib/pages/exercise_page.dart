import 'package:flutter/material.dart';
import 'package:routing/pages/gym_page.dart';
import '../pages/results_page.dart';
import '../constants/constants.dart';
import '../constants/sizes.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  @override
  Widget build(BuildContext context) {
    Sizes().initialize(context);

    return Scaffold(
      backgroundColor: white,
      body: SafeArea(child: Scaffold(
        backgroundColor: white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Exercise-Page",
                style: TextStyle(
                    color: black,
                    fontSize: Sizes.textSizeBig
                ),
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: Sizes.paddingBig, vertical: Sizes.paddingSmall),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.5),
                        color: green,
                      ),
                      child: Text(
                        "Go To Gym-Page",
                        style: TextStyle(
                            color: white,
                            fontSize: Sizes.textSizeSmall
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32), // Abstand zwischen Text und Buttons
                  GestureDetector(
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ResultsPage()),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: Sizes.paddingBig, vertical: Sizes.paddingSmall),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.5),
                        color: darkGreen,
                      ),
                      child: Text(
                        "Go To Results-Page",
                        style: TextStyle(
                            color: white,
                            fontSize: Sizes.textSizeSmall
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )),
    );
  }
}
