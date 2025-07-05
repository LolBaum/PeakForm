import 'package:flutter/material.dart';
import 'constants/constants.dart';
import 'l10n/app_localizations.dart';

class FeedbackItem {
  final String label;
  final String? timestamp;
  FeedbackItem({required this.label, this.timestamp});
}

class ResultScreen extends StatelessWidget {
  final List<FeedbackItem> goodFeedback;
  final List<FeedbackItem> badFeedback;
  final List<FeedbackItem> tips;

  const ResultScreen({
    super.key,
    required this.goodFeedback,
    required this.badFeedback,
    required this.tips,
  });

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              color: AppColors.primary
                                  .withAlpha((255 * 0.1).toInt()),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Center(
                              child: Icon(Icons.directions_run,
                                  size: 100, color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(translation.feedback_title,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          _feedbackCard(context, translation.tooltip_good,
                              AppColors.primary, goodFeedback),
                          const SizedBox(height: 12),
                          _feedbackCard(
                              context, "ffoo", AppColors.error, badFeedback),
                          const SizedBox(height: 24),
                          Text(translation.result_tips,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          _tipsCard(context, tips),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(translation.result_continue,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
              ],
            );
          },
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
                  fontSize: AppFontSizes.small,
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
          const Icon(Icons.circle, size: 8, color: AppColors.onSurface),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
