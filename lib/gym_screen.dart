import 'package:flutter/material.dart';
import 'package:fitness_app/util/logging_service.dart';
import 'constants/constants.dart';
import 'l10n/app_localizations.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class GymExercise {
  final String label;
  final String videoPath;
  const GymExercise({required this.label, required this.videoPath});
}

class GymScreen extends StatelessWidget {
  const GymScreen({super.key});
  // TODOD: Localize
  final List<String> filters = const [
    'Lower Body',
    'Equipment',
    'Abs',
    'Brust',
    'Rücken',
    'Arme',
    'Po'
  ];
  // TODOD: Localize
  final List<GymExercise> exercises = const [
    GymExercise(
      label: 'Dumbbell Lateral Raises',
      videoPath: 'assets/videos/gym/Dumbbell-Lateral-Raises.mov',
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
              // TODO: Use constants
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
                            Navigator.pop(context);
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
                          (label == 'Lower Body' || label == 'Equipment');
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
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.listItem),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: () => _openExerciseVideo(
                                  context,
                                  exercise.videoPath,
                                  exercise.label.replaceAll(' ', '_')),
                              splashColor: AppColors.primary
                                  .withAlpha((255 * 0.2).toInt()),
                              highlightColor: AppColors.primary
                                  .withAlpha((255 * 0.1).toInt()),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppGaps.gap16),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 12),
                                    Text('${index + 1}',
                                        style: const TextStyle(
                                            color: AppColors.onPrimary,
                                            fontWeight: AppFontWeights.bold)),
                                    const SizedBox(width: 12),
                                    Container(
                                      width: 35,
                                      height: 35,
                                      decoration: const BoxDecoration(
                                          color: AppColors.secondary,
                                          shape: BoxShape.circle),
                                      child: const Center(
                                        child: Icon(Icons.play_arrow,
                                            size: 18, color: AppColors.surface),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        exercise.label,
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
