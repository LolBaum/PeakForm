import 'package:flutter/material.dart';
import 'constants/constants.dart';
import 'l10n/app_localizations.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:typed_data';
import 'package:open_file/open_file.dart';

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

  const ResultScreen({
    super.key,
    required this.goodFeedback,
    required this.badFeedback,
    required this.tips,
    this.videoPath,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  Uint8List? _thumbnailBytes;
  bool _loadingThumbnail = false;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
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
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: widget.videoPath != null
                        ? _openVideoWithSystemPlayer
                        : null,
                    splashColor:
                        AppColors.primary.withAlpha((255 * 0.2).toInt()),
                    highlightColor:
                        AppColors.primary.withAlpha((255 * 0.1).toInt()),
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha((255 * 0.1).toInt()),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: widget.videoPath != null
                          ? (_loadingThumbnail
                              ? const Center(child: CircularProgressIndicator())
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
                                            child: Icon(Icons.play_circle_fill,
                                                color: Colors.white, size: 64),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 400,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamedAndRemoveUntil('/', (route) => false),
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
}
