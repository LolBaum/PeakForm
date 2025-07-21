import 'package:flutter/material.dart';
import 'package:google_ml_kit_example/services/performance_service.dart';
import 'package:google_ml_kit_example/vision_detector_views/feedback_generator.dart';
import 'constants/constants.dart';
import 'l10n/app_localizations.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:typed_data';
import 'package:open_file/open_file.dart';
import 'vision_detector_views/feedback_generator.dart';

class FeedbackItem {
  final String label;
  final String? timestamp;
  FeedbackItem({required this.label, this.timestamp});
}

// TODO: Renaming to FeedbackScreen
class ResultScreen extends StatefulWidget {
  final List<FeedbackItem> goodFeedback;
  final List<FeedbackItem> badFeedback;
  final List<FeedbackItem> tips;
  final String? videoPath;
  final int score;

  const ResultScreen({
    super.key,
    required this.goodFeedback,
    required this.badFeedback,
    required this.tips,
    this.videoPath,
    required this.score,
  });



  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  Uint8List? _thumbnailBytes;
  bool _loadingThumbnail = false;
  bool _loadingVideo = false;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
    errorCounters.updateAll((key, value) => 0);
  }

  Future<void> _generateThumbnail() async {
    if (widget.videoPath == null) return;
    setState(() => _loadingThumbnail = true);
    try {
      final bytes = await VideoThumbnail.thumbnailData(
        video: widget.videoPath!,
        imageFormat: ImageFormat.PNG,
        maxWidth: 400,
        quality: 75,
      );
      if (mounted) {
        setState(() {
          _thumbnailBytes = bytes;
        });
      }
    } catch (e) {
      // ignore
    } finally {
      if (mounted) setState(() => _loadingThumbnail = false);
    }
  }

  Future<void> _openVideoWithSystemPlayer() async {
    if (widget.videoPath == null) return;
    try {
      await OpenFile.open(widget.videoPath!);
    } catch (e) {
      if (mounted) {
        // TODO: translation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Konnte Video nicht öffnen: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final translation = AppLocalizations.of(context)!;
    //final userName = Provider.of<AuthProvider>(context).userName ?? 'User';
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          translation.result_title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12), // Optional padding for spacing
            child: GestureDetector(
              onTap: () {
                _viewSavedScores(); // Your function
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.history,
                  color: AppColors.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: true,
        bottom: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Stack(
                  children: [
                    GestureDetector(
                      onTap: widget.videoPath != null && !_loadingVideo
                          ? () async {
                              setState(() => _loadingVideo = true);
                              await _openVideoWithSystemPlayer();
                              if (mounted) {
                                setState(() => _loadingVideo = false);
                              }
                            }
                          : null,
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color:
                              AppColors.primary.withAlpha((255 * 0.1).toInt()),
                        ),
                        child: widget.videoPath != null
                            ? (_loadingThumbnail
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : _thumbnailBytes != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(25),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.memory(_thumbnailBytes!,
                                                fit: BoxFit.cover),
                                            Container(
                                                color: Colors.black.withAlpha(
                                                    (255 * 0.2).toInt())),
                                            const Center(
                                              child: Icon(
                                                  Icons.play_circle_fill,
                                                  color: Colors.white,
                                                  size: 64),
                                            ),
                                          ],
                                        ),
                                      )
                                    : const Center(
                                        child: Icon(Icons.play_circle_fill,
                                            color: Colors.white, size: 64),
                                      ))
                            : const Center(
                                child: Icon(Icons.directions_run,
                                    size: 100, color: AppColors.primary),
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
                const SizedBox(height: 16),
                Text(translation.feedback_title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                _feedbackCard(context, translation.tooltip_good,
                    AppColors.primary, widget.goodFeedback),
                const SizedBox(height: 12),
                _feedbackCard(context, translation.tooltip_bad, AppColors.error,
                    widget.badFeedback),
                const SizedBox(height: 24),
                Text(translation.result_tips,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _tipsCard(context, widget.tips),
                const SizedBox(height: 32),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${widget.score}%', //score
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                //performance history
               /* Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 400,
                    child: ElevatedButton(
                      onPressed: _viewSavedScores,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 8,
                      ),
                      child: Text('View Performance History',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  ),
                ),*/
                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 400,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamedAndRemoveUntil('/gym', (route) => false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 8,
                      ),
                      child: Text(translation.primary_button_close,
                          style: const TextStyle(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _feedbackCard(BuildContext context, String label, Color color,
      List<FeedbackItem> items) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Tooltip label
        Positioned(
          right: 16,
          top: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: ShapeDecoration(
              color: color,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color: Colors.black.withAlpha((255 * 0.1).toInt()),
                ),
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
        // Card background (dynamic height, sits directly below tooltip)
        Container(
          margin: const EdgeInsets.only(
              top: 24), // Only enough to clear the tooltip label
          width: double.infinity,
          decoration: ShapeDecoration(
            color: color == AppColors.primary
                ? const Color(0x1E767680)
                : const Color(0x1ECB5D4E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppPaddings.all16.left, vertical: AppGaps.gap20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items
                  .map((item) => _feedbackRow(
                      color == AppColors.primary, item.label, item.timestamp))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _feedbackRow(bool good, String text, String? timestamp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppGaps.gap4),
      child: Row(
        children: [
          Icon(good ? Icons.check_circle : Icons.error,
              color: good ? AppColors.primary : AppColors.error, size: 16),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          if (timestamp != null)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                timestamp,
                style: const TextStyle(
                  color: AppColors.darkGrey,
                  fontSize: AppFontSizes.subtitle,
                  fontWeight: AppFontWeights.medium,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tipsCard(BuildContext context, List<FeedbackItem> tips) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: tips.map((tip) => _tipRow(tip.label)).toList(),
      ),
    );
  }

  Widget _tipRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppGaps.gap4),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 16, color: AppColors.onSurface),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: AppFontSizes.body,
                      fontWeight: AppFontWeights.bold))),
        ],
      ),
    );
  }
  Future<void> _viewSavedScores() async {
    double? latestScore = await PerformanceService.getLatestScore();
    List<Map<String, dynamic>> allScoresWithTimestamps = await PerformanceService.getAllScoresWithTimestamps();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Performance History'),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Latest Score: ${latestScore?.toStringAsFixed(2) ?? 'None'}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Total Sessions: ${allScoresWithTimestamps.length}'),
              SizedBox(height: 10),
              Expanded(
                child: allScoresWithTimestamps.isEmpty
                    ? Center(child: Text('No performance data yet.\n\nStart exercising to see your scores!'))
                    : ListView.builder(
                  itemCount: allScoresWithTimestamps.length,
                  itemBuilder: (context, index) {
                    final scoreData = allScoresWithTimestamps[index];
                    final score = scoreData['score'] as double;
                    final formattedTime = scoreData['formattedTime'] as String;

                    final duration = scoreData['duration'] as String;

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                        backgroundColor: AppColors.primary,
                      ),
                      title: Text('Score: ${score.toStringAsFixed(2)}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$formattedTime ${index == 0 ? '(Most Recent)' : ''}'),
                          Text('Duration: $duration',
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      isThreeLine: true,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }}
