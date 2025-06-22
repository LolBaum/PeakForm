import 'package:flutter/material.dart';
import 'gym_page.dart';
import '../constants/constants.dart';
import '../constants/sizes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
                "Home-Page",
                style: TextStyle(
                    color: black,
                    fontSize: Sizes.textSizeBig
                ),
              ),
              GestureDetector(
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GymPage()),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: Sizes.paddingBig, vertical: Sizes.paddingSmall),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.5),
                    color: darkGreen,
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
            ],
          ),
        ),
      )),
    );
  }
}
