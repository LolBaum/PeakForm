import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

double translateX(
  double x,
  Size canvasSize,
  Size imageSize,
  InputImageRotation rotation,
  CameraLensDirection cameraLensDirection,
) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
      // portrait-DOWN (rotation90deg): back camera unmirrored, front camera mirrored
      if (cameraLensDirection == CameraLensDirection.back) {
        return x *
            canvasSize.width /
            (Platform.isIOS ? imageSize.width : imageSize.height);
      }
      return canvasSize.width -
          x *
              canvasSize.width /
              (Platform.isIOS ? imageSize.width : imageSize.height);
    case InputImageRotation.rotation270deg:
      // portrait-UP (rotation270deg): back camera unmirrored, front camera mirrored
      if (cameraLensDirection == CameraLensDirection.back) {
        return x *
            canvasSize.width /
            (Platform.isIOS ? imageSize.width : imageSize.height);
      }
      return canvasSize.width -
          x *
              canvasSize.width /
              (Platform.isIOS ? imageSize.width : imageSize.height);
    case InputImageRotation.rotation0deg:
    case InputImageRotation.rotation180deg:
      // landscape-LEFT (0deg) and landscape-RIGHT (180deg)
      if (cameraLensDirection == CameraLensDirection.back) {
        // Back camera unmirrored
        return x * canvasSize.width / imageSize.width;
      }
      // Front camera mirrored
      return canvasSize.width - x * canvasSize.width / imageSize.width;
  }
}

double translateY(
  double y,
  Size canvasSize,
  Size imageSize,
  InputImageRotation rotation,
  CameraLensDirection cameraLensDirection,
) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
    case InputImageRotation.rotation270deg:
      return y *
          canvasSize.height /
          (Platform.isIOS ? imageSize.height : imageSize.width);
    case InputImageRotation.rotation0deg:
    case InputImageRotation.rotation180deg:
      // For 180deg rotation (upside down), flip the Y coordinate
   /*   if (rotation == InputImageRotation.rotation180deg) {
        return canvasSize.height - y * canvasSize.height / imageSize.height;
      }*/
      return y * canvasSize.height / imageSize.height;
  }
}

/*
   portrait-UP          270° (rotation270deg)
   portrait-DOWN       90°  (rotation90deg)
   landscape-LEFT      0°   (rotation0deg)
   landscape-RIGHT     180° (rotation180deg)
*/