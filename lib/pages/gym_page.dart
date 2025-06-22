import 'package:flutter/material.dart';
import 'package:routing/pages/home_page.dart';
import '../pages/exercise_page.dart';
import '../constants/constants.dart';
import '../constants/sizes.dart';

class GymPage extends StatefulWidget {
  const GymPage({super.key});

  @override
  State<GymPage> createState() => _GymPageState();
}

class _GymPageState extends State<GymPage> {
  @override
  Widget build(BuildContext context) {
    Sizes().initialize(context);

    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
          child: Scaffold(
        backgroundColor: white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Gym-Page",
                style: TextStyle(
                    color: black,
                    fontSize: Sizes.textSizeBig
                ),
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: Sizes.paddingBig, vertical: Sizes.paddingSmall),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.5),
                        color: green,
                      ),
                      child: Text(
                        "Go To Home-Page",
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
                        MaterialPageRoute(builder: (context) => ExercisePage()),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: Sizes.paddingBig, vertical: Sizes.paddingSmall),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.5),
                        color: darkGreen,
                      ),
                      child: Text(
                        "Go To Exercise-Page",
                        style: TextStyle(
                            color: white,
                            fontSize: Sizes.textSizeSmall
                        ),
                      ),
                    ),
                  ),
                ]
              ),

            ],
          ),
        ),
      )),
    );
  }
}
