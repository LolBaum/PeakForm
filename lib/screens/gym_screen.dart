import '../exercise_screen.dart';
import 'package:flutter/material.dart';
import '../util/logging_service.dart';
import '../constants/constants.dart';
import '../l10n/app_localizations.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../vision_detector_views/exerciseType.dart';
import '../vision_detector_views/globals.dart';
import '../vision_detector_views/pose_detector_view.dart';

class GymExercise {
  final ExerciseType exerciseType;
  final String label;
  final String videoPath;
  final String thumbnailPath;
  final List<String> exerciseTags;
  final List<String> executionSteps;
  const GymExercise({
    required this.exerciseType,
    required this.label,
    required this.videoPath,
    required this.thumbnailPath,
    required this.exerciseTags,
    required this.executionSteps,
  });
}

class GymScreen extends StatelessWidget {
  const GymScreen({super.key});
  // TODOD: Localize
  final List<String> filters = const [
    'Core',
    'Freihanteln',
    'Arme',
    'Rücken',
    'Becken',
    'Trizeps',
    'Hamstrings',
    'Quadrizeps',
    'Schulter',
  ];
  // TODOD: Localize
  final List<GymExercise> exercises = const [
    GymExercise(
      exerciseType: ExerciseType.lateralRaises,
      label: 'Lateral Raises',
      videoPath: 'assets/videos/gym/Dumbbell-Lateral-Raises.mov',
      thumbnailPath:
          'assets/images/thumbnail/thumbnail-dumbbell-lateral-raises.jpeg',
      exerciseTags: ['Schulter', 'Freihanteln'],
      executionSteps: [
        'Stelle dich schulterbreit hin und halte in jeder Hand eine Kurzhantel.',
        'Hebe die Arme seitlich bis auf Schulterhöhe.',
        'Senke die Hanteln langsam wieder ab.',
      ],
    ),
    GymExercise(
      exerciseType: ExerciseType.bicepCurls,

      label: 'Bicep Curls',
      videoPath: 'assets/videos/biceps/biceps-curls.mov',
      thumbnailPath: 'assets/images/thumbnail/thumbnail-biceps-curls.jpeg',
      exerciseTags: ['Arme', 'Freihanteln'],
        executionSteps: [
          'Stelle dich schulterbreit hin, die Knie leicht gebeugt.',
          'Halte in jeder Hand eine Kurzhantel mit den Handflächen nach vorne.',
          'Bewege die Unterarme und führe die Hanteln langsam Richtung Schultern.',
          'Halte die Position kurz oben für maximale Muskelspannung.',
          'Senke die Hanteln kontrolliert zurück in die Ausgangsposition.',
        ]
    ),
    GymExercise(
      exerciseType: ExerciseType.lunges,

      label: 'Side Lunges',
      videoPath: 'assets/videos/lunges/lunges.mov',
      thumbnailPath: 'assets/images/thumbnail/thumbnail-lunges.jpeg',
      exerciseTags: ['Beine', 'Quadrizeps', 'Hamstrings'],
      executionSteps: [
        'Stelle dich aufrecht hin.',
        'Mache einen großen Schritt nach vorne und senke das hintere Knie ab.',
        'Drücke dich zurück in die Ausgangsposition.',
      ],
    ),
    // Add more exercises here as needed
  ];

  Future<void> _openExerciseVideo(
      BuildContext context, String videoAsset, String label) async {
    try {
      final byteData = await DefaultAssetBundle.of(context).load(videoAsset);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$label.mov');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      await OpenFile.open(file.path);
    } catch (e, stack) {
      LoggingService.instance.e('Konnte Video für $label nicht öffnen',
          error: e, stackTrace: stack);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Konnte Video nicht öffnen: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final translation = AppLocalizations.of(context)!;
    LoggingService.instance.i('GymScreen displayed');
    tips.clear();
    return Scaffold(
      // TODO: Use constants
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Stack(
          children: [
            //Positioned.fill(
            //  child: Image.asset(
            //    'assets/gym_background.png',
            //    fit: BoxFit.cover,
            //    alignment: Alignment.topRight,
            //  ),
            //),
            Padding(
              // TODO: Route back to Homescreen
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () {
                            LoggingService.instance
                                .i('User navigated back from gym screen');
                            Navigator.pop(context); //TODO: fehler
                          },
                          icon: const Icon(Icons.arrow_back)),
                      const Icon(Icons.star, color: darkGreen, size: 28),
                    ],
                  ),
                  // TODOD: Localize
                  const SizedBox(height: 16), //TODO: Check height
                  const Text('MEISTER DEINE',
                      style: TextStyle(
                          fontSize: AppFontSizes.headline,
                          fontWeight: AppFontWeights.extraBold)),
                  const Text('POSE IM GYM',
                      style: TextStyle(
                          fontSize: AppFontSizes.headline,
                          fontWeight: AppFontWeights.extraBold)),
                  const SizedBox(height: 16), //TODO: Check height
                  Wrap(
                    spacing: 10,
                    runSpacing: 0,
                    children: filters.map((label) {
                      // TODOD: Localize
                      final bool selected =
                          (label == 'Core' || label == 'Freihanteln');
                      return Chip(
                        label: Text(label,
                            style: TextStyle(
                                color: selected
                                    ? AppColors.onPrimary
                                    : AppColors.darkGrey,
                                fontWeight: AppFontWeights.bold)),
                        backgroundColor:
                            selected ? AppColors.primary : AppColors.lightGrey,
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.chip,
                            vertical: AppGaps.gap4),
                        shape: const StadiumBorder(),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16), //TODO: Check height
                  Text(
                    translation.gym_improve_flexibility,
                    style: const TextStyle(
                        height: 1.4, fontWeight: AppFontWeights.bold),
                  ),
                  const SizedBox(height: 4), //TODO: Check height
                  Text(
                    translation.gym_course_feedback,
                    style: const TextStyle(
                        height: 1.4, fontWeight: AppFontWeights.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = exercises[index];
                        return _GymExerciseListItem(
                          index: index,
                          exercise: exercise,
                          openExercise: () async {
                            final bytes = await DefaultAssetBundle.of(context)
                                .load(exercise.thumbnailPath);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExerciseScreen(
                                  title: exercise.label,
                                  videoAsset: exercise.videoPath,
                                  thumbnailBytes: bytes.buffer.asUint8List(),
                                  executionSteps: exercise.executionSteps,
                                  exerciseTags: exercise.exerciseTags,
                                  exerciseType: exercise.exerciseType,
                                  onPlayVideo: () async {
                                    final scaffoldContext = context;
                                    try {
                                      final byteData =
                                          await DefaultAssetBundle.of(
                                                  scaffoldContext)
                                              .load(exercise.videoPath);
                                      final tempDir =
                                          await getTemporaryDirectory();
                                      final file = File(
                                          '${tempDir.path}/${exercise.label.replaceAll(' ', '_')}.mov');
                                      await file.writeAsBytes(
                                          byteData.buffer.asUint8List());
                                      await OpenFile.open(file.path);
                                    } catch (e, stack) {
                                      LoggingService.instance.e(
                                          'Konnte Video für ${exercise.label} nicht öffnen',
                                          error: e,
                                          stackTrace: stack);
                                      if (!scaffoldContext.mounted) return;
                                      ScaffoldMessenger.of(scaffoldContext)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Konnte Video nicht öffnen: $e')),
                                      );
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                          openVideo: () async {
                            await _openExerciseVideo(
                              context,
                              exercise.videoPath,
                              exercise.label.replaceAll(' ', '_'),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GymExerciseListItem extends StatefulWidget {
  final int index;
  final GymExercise exercise;
  final VoidCallback openExercise;
  final Future<void> Function() openVideo;
  const _GymExerciseListItem({
    required this.index,
    required this.exercise,
    required this.openExercise,
    required this.openVideo,
  });

  @override
  State<_GymExerciseListItem> createState() => _GymExerciseListItemState();
}

class _GymExerciseListItemState extends State<_GymExerciseListItem> {
  bool _isPressed = false;
  bool _iconPressed = false;
  bool _loadingVideo = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.listItem),
      decoration: BoxDecoration(
        color: _isPressed ? AppColors.secondary : AppColors.primary,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: widget.openExercise,
          onHighlightChanged: (v) => setState(() => _isPressed = v),
          splashColor: Colors.white.withAlpha((255 * 0.2).toInt()),
          highlightColor: Colors.white.withAlpha((255 * 0.1).toInt()),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppGaps.gap16),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Text('${widget.index + 1}',
                    style: const TextStyle(
                        color: AppColors.onPrimary,
                        fontWeight: AppFontWeights.bold)),
                const SizedBox(width: 12),
                GestureDetector(
                  onTapDown: (_) => setState(() => _iconPressed = true),
                  onTapUp: (_) => setState(() => _iconPressed = false),
                  onTapCancel: () => setState(() => _iconPressed = false),
                  onTap: _loadingVideo
                      ? null
                      : () async {
                          setState(() => _loadingVideo = true);
                          try {
                            await widget.openVideo();
                          } finally {
                            if (mounted) setState(() => _loadingVideo = false);
                          }
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    curve: Curves.easeInOut,
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: _iconPressed
                          ? AppColors.primary
                          : AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: _loadingVideo
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.surface),
                              ),
                            )
                          : const Icon(Icons.play_arrow,
                              size: 18, color: AppColors.surface),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.exercise.label,
                    style: const TextStyle(
                      fontWeight: AppFontWeights.bold,
                      color: AppColors.onPrimary,
                      fontSize: AppFontSizes.body,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
