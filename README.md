# PeakForm - AI-Powered Pose Detection App

A Flutter application implementing Google's MoveNet model for real-time pose detection using TensorFlow Lite.

## Features

- **Real-time pose detection** using MoveNet SinglePose Lightning model
- **17 body keypoints** detection with confidence scores
- **High-performance processing** at 25-28 FPS on mobile devices
- **Live camera preview** with pose overlay visualization
- **Android support** with NDK 28.1.13356709

## MoveNet Model

This app uses the MoveNet SinglePose Lightning model (`3.tflite`):
- **Model**: MoveNet SinglePose Lightning TFLite Float32
- **Input size**: 192x192 pixels
- **Output**: 17 body keypoints with [y, x, confidence] coordinates
- **Performance**: Optimized for real-time mobile applications

### Detected Keypoints

The model detects 17 body keypoints:

1. Nose (0)
2. Left Eye (1)
3. Right Eye (2)
4. Left Ear (3)
5. Right Ear (4)
6. Left Shoulder (5)
7. Right Shoulder (6)
8. Left Elbow (7)
9. Right Elbow (8)
10. Left Wrist (9)
11. Right Wrist (10)
12. Left Hip (11)
13. Right Hip (12)
14. Left Knee (13)
15. Right Knee (14)
16. Left Ankle (15)
17. Right Ankle (16)

## Technical Specifications

- **NDK Version**: 28.1.13356709 (Latest)
- **Min SDK**: 21 (Android 5.0+)
- **Target Platform**: Android (iOS support available)
- **TensorFlow Lite**: Float32 model with normalized input
- **Flutter**: Compatible with Flutter 3.x
- **Camera Resolution**: Low resolution for optimal performance

## Performance Metrics

- **FPS**: 25-28 FPS consistently on modern Android devices
- **Inference Time**: Optimized with frame skipping (every 2nd frame)
- **Memory Usage**: Efficient with TensorFlow Lite
- **Confidence Threshold**: Adjustable (currently 0.01 for maximum sensitivity)

## Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd PeakForm
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Ensure the MoveNet model is in place**
   - The `3.tflite` model should be in `assets/models/3.tflite`
   - This is the MoveNet SinglePose Lightning model

4. **Build and run**
   ```bash
   flutter clean
   flutter run
   ```

## Usage

1. Launch the app on an Android device
2. Grant camera permissions when prompted
3. Tap "Start Detection" to begin real-time pose detection
4. **Blue dots** show all 17 detected keypoints
5. **Green dots** show high-confidence keypoints (>0.05)
6. **White numbers** indicate keypoint indices (0-16)
7. **Red lines** connect confident keypoints to form skeleton

## Development Features

- **Debug visualization** with keypoint indices
- **Real-time confidence scores** for each keypoint
- **Performance monitoring** with FPS counter
- **Input tensor validation** with min/max/average statistics
- **Frame processing statistics** every 100 frames

## Requirements

- **Android Device**: Required (web/desktop not supported)
- **Camera Access**: Front camera for pose detection
- **NDK 28.1.13356709**: For optimal TensorFlow Lite performance
- **Good Lighting**: Improves detection accuracy

## Project Structure

```
lib/
├── main.dart                         # App entry point
├── providers/
│   └── pose_detection_provider.dart  # MoveNet inference & camera handling
├── screens/
│   ├── home_screen.dart             # Landing page  
│   └── pose_detection_screen.dart    # Camera UI with pose overlay
└── widgets/
    └── pose_painter.dart            # Real-time pose visualization

assets/
└── models/
    └── 3.tflite                     # MoveNet SinglePose Lightning model

android/
└── app/
    └── build.gradle                 # NDK 28.1.13356709 configuration
```

## Model Configuration

- **Input Format**: Float32 values (0.0-1.0) normalized RGB
- **Output Format**: [1, 1, 17, 3] tensor with [y, x, confidence] per keypoint
- **Coordinate System**: Normalized (0.0-1.0) relative to image dimensions
- **Front Camera**: Horizontally mirrored for natural selfie view

## Known Issues

- Model file validation required - ensure correct MoveNet model is used
- Best performance on devices with dedicated AI/NPU acceleration
- Lighting conditions significantly affect detection quality

## References

- [MoveNet TensorFlow Hub](https://tfhub.dev/google/movenet/singlepose/lightning/4)
- [MoveNet Tutorial](https://www.tensorflow.org/hub/tutorials/movenet)
- [TensorFlow Lite Flutter Plugin](https://pub.dev/packages/tflite_flutter)
- [NDK Documentation](https://developer.android.com/ndk)

## License

This project uses the MoveNet model which is licensed under Apache 2.0.
