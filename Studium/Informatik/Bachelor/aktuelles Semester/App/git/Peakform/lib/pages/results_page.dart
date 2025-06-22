import 'package:flutter/material.dart';
import 'package:routing/pages/exercise_page.dart';
import '../constants/constants.dart';
import '../constants/sizes.dart';
import 'home_page.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});


  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  @override
  Widget build(BuildContext context) {
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
                    "Results-Page",
                    style: TextStyle(
                        color: black,
                        fontSize: Sizes.textSizeBig
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(
                        context,
                        MaterialPageRoute(builder: (context) => ExercisePage()),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: Sizes.paddingBig, vertical: Sizes.paddingSmall),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.5),
                        color: green,
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
                ],
              ),
            ),
          )
      ),
    );
  }
}
