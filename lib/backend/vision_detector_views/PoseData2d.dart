import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'tool.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseData2D {
  Vector2? shoulder;
  Vector2? elbow;
  Vector2? wrist;
  Vector2? hip;

  PoseData2D({this.shoulder, this.elbow, this.wrist, this.hip});

  bool get isComplete => shoulder != null && elbow != null && wrist != null && hip != null;
}
