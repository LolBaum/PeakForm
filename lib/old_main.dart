import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'vision_detector_views/pose_detector_view.dart';
import 'vision_detector_views/exerciseType.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //not secure
  //sowie native_device_orientation-1.2
  //import 'package:flutter/services.dart'; was dafür verwendet wurde
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);


  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PeakForm'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
              child: Column(
                children: [
                      CustomCard(exerciseTypeToString(ExerciseType.lateralRaises), PoseDetectorView(exerciseName: ExerciseType.lateralRaises,)),
                      CustomCard( exerciseTypeToString(ExerciseType.bicepCurls), PoseDetectorView(exerciseName: ExerciseType.bicepCurls,)),
                ],
              ),

        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final String _label;
  final Widget _viewPage;
  final bool featureCompleted;

  const CustomCard(this._label, this._viewPage, {this.featureCompleted = true});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        tileColor: Theme.of(context).primaryColor,
        title: Text(
          _label,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          if (!featureCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content:
                    const Text('This feature has not been implemented yet')));
          } else {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => _viewPage));
          }
        },
      ),
    );
  }
}
