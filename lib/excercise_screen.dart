import 'package:flutter/material.dart';
import 'constants/constants.dart';
import 'package:fitness_app/util/logging_service.dart';
import 'l10n/app_localizations.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class ExcerciseScreen extends StatefulWidget {
  const ExcerciseScreen({super.key});

  @override
  State<ExcerciseScreen> createState() => _ExcerciseScreenState();
}

class _ExcerciseScreenState extends State<ExcerciseScreen> {
  Uint8List? _thumbnailBytes;
  bool _loadingThumbnail = false;
  final String videoAsset = 'assets/videos/gym/Dumbbell-Lateral-Raises.mov';

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  Future<void> _generateThumbnail() async {
    setState(() => _loadingThumbnail = true);
    try {
      final bytes = await VideoThumbnail.thumbnailData(
        video: videoAsset,
        imageFormat: ImageFormat.PNG,
        maxWidth: 400,
        quality: 75,
      );
      if (mounted) {
        setState(() {
          _thumbnailBytes = bytes;
        });
      }
    } catch (e, stack) {
      LoggingService.instance
          .e('Failed to generate video thumbnail', error: e, stackTrace: stack);
    } finally {
      if (mounted) setState(() => _loadingThumbnail = false);
    }
  }

  Future<void> _openVideoWithSystemPlayer() async {
    try {
      final byteData = await rootBundle.load(videoAsset);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/Dumbbell-Lateral-Raises.mov');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      await OpenFile.open(file.path);
    } catch (e, stack) {
      LoggingService.instance.e('Konnte Video nicht mit Systemplayer öffnen',
          error: e, stackTrace: stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Konnte Video nicht öffnen: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final translation = AppLocalizations.of(context)!;
    LoggingService.instance.i('Excercise detail screen displayed');

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
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
                GestureDetector(
                  onTap: _openVideoWithSystemPlayer,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.primary.withAlpha((255 * 0.1).toInt()),
                    ),
                    child: _loadingThumbnail
                        ? const Center(child: CircularProgressIndicator())
                        : _thumbnailBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.memory(_thumbnailBytes!,
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
                          style:
                              const TextStyle(fontWeight: AppFontWeights.bold))
                    ]),
                    Column(children: [
                      Text(translation.video_difficulty,
                          style: const TextStyle(
                              fontSize: AppFontSizes.small,
                              fontWeight: AppFontWeights.bold)),
                      Text(translation.video_difficulty_value,
                          style:
                              const TextStyle(fontWeight: AppFontWeights.bold))
                    ]),
                    Column(children: [
                      Text(translation.video_intensity,
                          style: const TextStyle(
                              fontSize: AppFontSizes.small,
                              fontWeight: AppFontWeights.bold)),
                      Text(translation.video_intensity_value,
                          style:
                              const TextStyle(fontWeight: AppFontWeights.bold))
                    ])
                  ],
                ),
                const SizedBox(height: AppGaps.gap16),
                ElevatedButton(
                  onPressed: () {
                    LoggingService.instance
                        .i('User pressed START button on video screen');
                    Navigator.pushNamed(context, '/pose_detection');
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
