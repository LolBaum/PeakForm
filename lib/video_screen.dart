import 'package:flutter/material.dart';
import 'constants/constants.dart';
import 'package:fitness_app/util/logging_service.dart';
import 'l10n/app_localizations.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final translation = AppLocalizations.of(context)!;
    LoggingService.instance.i('VideoScreen displayed');

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: () {
                    LoggingService.instance
                        .i('User navigated back from video screen');
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back)),
              const SizedBox(height: AppGaps.gap16),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                    child: Icon(Icons.play_circle_fill,
                        color:
                            AppColors.onPrimary.withAlpha((255 * 0.6).toInt()),
                        size: 64)),
              ),
              const SizedBox(height: AppGaps.gap16),
              Text(translation.video_running,
                  style: const TextStyle(
                      fontSize: AppFontSizes.headline,
                      fontWeight: AppFontWeights.bold)),
              const SizedBox(height: AppGaps.gap8),
              Wrap(
                spacing: AppSpacing.icon,
                children: [
                  _laufenTag(translation.video_calf),
                  _laufenTag(translation.video_thigh),
                ],
              ),
              const Divider(height: 32, thickness: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(children: [
                    Text(translation.video_duration,
                        style: const TextStyle(
                            fontSize: AppFontSizes.small,
                            fontWeight: AppFontWeights.bold)),
                    Text(translation.video_duration_value,
                        style: const TextStyle(fontWeight: AppFontWeights.bold))
                  ]),
                  Column(children: [
                    Text(translation.video_difficulty,
                        style: const TextStyle(
                            fontSize: AppFontSizes.small,
                            fontWeight: AppFontWeights.bold)),
                    Text(translation.video_difficulty_value,
                        style: const TextStyle(fontWeight: AppFontWeights.bold))
                  ]),
                  Column(children: [
                    Text(translation.video_intensity,
                        style: const TextStyle(
                            fontSize: AppFontSizes.small,
                            fontWeight: AppFontWeights.bold)),
                    Text(translation.video_intensity_value,
                        style: const TextStyle(fontWeight: AppFontWeights.bold))
                  ])
                ],
              ),
              const SizedBox(height: AppGaps.gap16),
              ElevatedButton(
                onPressed: () {
                  LoggingService.instance
                      .i('User pressed START button on video screen');
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
              Text(
                translation.video_course_description,
                style: const TextStyle(
                    color: Colors.grey, fontWeight: AppFontWeights.bold),
              ),
              const SizedBox(height: AppGaps.gap8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha((255 * 0.05).toInt()),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  translation.video_course_description,
                  style: const TextStyle(fontWeight: AppFontWeights.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _laufenTag(String text) {
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
