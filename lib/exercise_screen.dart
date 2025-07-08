import 'package:flutter/material.dart';
import 'constants/constants.dart';
import 'package:fitness_app/util/logging_service.dart';
import 'package:flutter/services.dart';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:fitness_app/providers/pose_detection_provider.dart';
import 'package:fitness_app/screens/camera_screen.dart';

class ExerciseScreen extends StatefulWidget {
  final String title;
  final String videoAsset;
  final Uint8List? thumbnailBytes;
  final List<String> executionSteps;
  final List<String> exerciseTags;
  final Future<void> Function()? onPlayVideo;
  final int? exerciseType;

  const ExerciseScreen({
    super.key,
    required this.title,
    required this.videoAsset,
    required this.thumbnailBytes,
    required this.executionSteps,
    required this.exerciseTags,
    this.onPlayVideo,
    this.exerciseType,
  });

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  bool _loadingVideo = false;

  @override
  Widget build(BuildContext context) {
    LoggingService.instance.i('Excercise detail screen displayed');
    final translation = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        LoggingService.instance
                            .i('User navigated back from video screen');
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          translation.exercise_screen_title,
                          style: const TextStyle(
                            fontSize: AppFontSizes.headline,
                            fontWeight: AppFontWeights.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: AppGaps.gap8),
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (widget.onPlayVideo != null) {
                          setState(() => _loadingVideo = true);
                          await widget.onPlayVideo!();
                          if (mounted) setState(() => _loadingVideo = false);
                        }
                      },
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color:
                              AppColors.primary.withAlpha((255 * 0.1).toInt()),
                        ),
                        child: widget.thumbnailBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.memory(widget.thumbnailBytes!,
                                        fit: BoxFit.cover),
                                    Container(
                                      color: Colors.black
                                          .withAlpha((255 * 0.2).toInt()),
                                    ),
                                    const Center(
                                      child: Icon(Icons.play_circle_fill,
                                          color: Colors.white, size: 64),
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [
                                    AppColors.primary,
                                    AppColors.secondary
                                  ]),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                    child: Icon(Icons.play_circle_fill,
                                        color: Colors.white54, size: 64)),
                              ),
                      ),
                    ),
                    if (_loadingVideo)
                      Positioned.fill(
                        child: Container(
                          color:
                              AppColors.primary.withAlpha((255 * 0.3).toInt()),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppGaps.gap8),
                Text(widget.title,
                    style: const TextStyle(
                        fontSize: AppFontSizes.headline,
                        fontWeight: AppFontWeights.bold)),
                const SizedBox(height: AppGaps.gap8),
                Wrap(
                  spacing: AppSpacing.icon,
                  children: widget.exerciseTags
                      .map((tag) => _exerciseTag(tag))
                      .toList(),
                ),
                const SizedBox(height: AppGaps.gap16),
                ElevatedButton(
                  onPressed: () {
                    LoggingService.instance
                        .i('User pressed START button on video screen');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider(
                          create: (_) => PoseDetectionProvider(),
                          child:
                              CameraScreen(exerciseType: widget.exerciseType),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text(translation.video_start,
                      style: const TextStyle(
                          fontSize: AppFontSizes.title,
                          fontWeight: AppFontWeights.bold,
                          color: Colors.white)),
                ),
                const SizedBox(height: AppGaps.gap16),
                ExecutionSteps(
                  title: translation.exercise_screen_execution_subtitle,
                  steps: widget.executionSteps,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _exerciseTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.icon, vertical: AppGaps.gap6),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: const TextStyle(
            fontWeight: AppFontWeights.bold, color: Colors.white),
      ),
    );
  }
}

class ExecutionSteps extends StatelessWidget {
  final String title;
  final List<String> steps;
  const ExecutionSteps({super.key, required this.title, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity - 15,
          height: 24,
          child: Stack(
            children: [
              Positioned(
                left: 20,
                top: 0,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'LeagueSpartan',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 18.06,
                child: Container(
                  transform: Matrix4.identity()..rotateZ(-1.57),
                  width: 16.12,
                  decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 4,
                        strokeAlign: BorderSide.strokeAlignCenter,
                        color: Color(0xFFD9D9D9),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(steps.length, (i) {
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 29,
                  height: 30,
                  decoration: const ShapeDecoration(
                    color: Color(0x1E767680),
                    shape: OvalBorder(),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'LeagueSpartan',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    steps[i],
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 16,
                      fontFamily: 'LeagueSpartan',
                      fontWeight: AppFontWeights.medium,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
