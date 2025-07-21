import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_ml_kit_example/vision_detector_views/exerciseType.dart';
import 'package:google_ml_kit_example/vision_detector_views/pose_detector_view.dart';
import 'constants/constants.dart';
import '../util/logging_service.dart';
import 'package:flutter/services.dart';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/pose_detection_provider.dart';
import '../screens/camera_screen.dart';
import '../vision_detector_views/exerciseType.dart';

class ExerciseScreen extends StatefulWidget {
  final ExerciseType exerciseType;
  final String title;
  final String videoAsset;
  final Uint8List? thumbnailBytes;
  final List<String> executionSteps;
  final List<String> exerciseTags;
  final Future<void> Function()? onPlayVideo;

  const ExerciseScreen({
    super.key,
    required this.title,
    required this.videoAsset,
    required this.thumbnailBytes,
    required this.executionSteps,
    required this.exerciseTags,
    this.onPlayVideo,
    required this.exerciseType,
  });

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  bool _loadingVideo = false;
  bool _showPaywall = false;

  @override
  Widget build(BuildContext context) {
    LoggingService.instance.i('Excercise detail screen displayed');
    final translation = AppLocalizations.of(context)!;
    if (_showPaywall) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: PaywallWidget(
            onClose: () => setState(() => _showPaywall = false),
          ),
        ),
      );
    }
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
                          "Details",
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
                    if (widget.exerciseType.name.toLowerCase() == 'laufen' || widget.exerciseType.name.toLowerCase() == 'running') {
                      setState(() => _showPaywall = true);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PoseDetectorView(exerciseType: widget.exerciseType)
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (widget.exerciseType.name.toLowerCase() == 'laufen' || widget.exerciseType.name.toLowerCase() == 'running')
                        ? const Color(0xFFFFC548)
                        : AppColors.secondary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text((widget.exerciseType.name.toLowerCase() == 'laufen' || widget.exerciseType.name.toLowerCase() == 'running') ? 'JETZT FREISCHALTEN' : translation.video_start,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontFamily: 'League Spartan',
                          fontWeight: FontWeight.w600,
                          height: 1.33)),
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

class PaywallWidget extends StatelessWidget {
  final VoidCallback? onClose;
  const PaywallWidget({Key? key, this.onClose}) : super(key: key);

  String _getDatePlus3Days() {
    final now = DateTime.now().add(const Duration(days: 3));
    final months = [
      '',
      'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'
    ];
    return '${now.day}. ${months[now.month]}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Top Row: Platzhalter, PREMIUM, X
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const SizedBox(width: 48), // Platzhalter wie IconButton auf ExerciseScreen
                Expanded(
                  child: Center(
                    child: Text(
                      'PREMIUM',
                      style: const TextStyle(
                        fontSize: AppFontSizes.headline,
                        fontWeight: AppFontWeights.bold,
                        //color: Color(0xFF232122),
                      //  fontFamily: 'League Spartan',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 24),
                    onPressed: onClose,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    child: Stack(
                      children: [
                        // PREMIUM und X sind jetzt oben in der Row
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),
                              const SizedBox(
                                width: 326,
                                child: Text(
                                  'Erhalte Zugang zu diesem Kurs',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF232122),
                                    fontSize: 25,
                                    fontFamily: 'League Spartan',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _paywallRow(
                                iconpath: 'assets/icons/IconConfirm.svg',
                                color: const Color(0xFF256F5D),
                                borderColor: const Color(0x4C256F5D),
                                title: 'Heute: Vollen Zugang',
                                subtitle: 'Genieße unbegrenzte Kurse',
                              ),
                              const SizedBox(height: 16),
                              _paywallRow(
                                iconpath: 'assets/icons/IconBell.svg',
                                color: Colors.white,
                                borderColor: const Color(0xFFEAF7FF),
                                title: 'Ein Tag vor der Probezeit',
                                subtitle: 'Erhalte eine Mail und Push-Notification',
                              ),
                              const SizedBox(height: 16),
                              _paywallRow(
                                iconpath: 'assets/icons/IconRocket.svg',
                                color: Colors.white,
                                borderColor: const Color(0xFFEAF7FF),
                                title: 'In 3 Tagen',
                                subtitle: 'Am ${_getDatePlus3Days()} belasten wir ihr Konto - Jederzeit vorher kündbar.',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            decoration: const ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color: Color(0xFFF9FAFE),
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 326,
                  child: Text(
                    '3,99€ / Woche nach Ablauf des Probeabos',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF232122),
                      fontSize: 17,
                      fontFamily: 'League Spartan',
                      fontWeight: FontWeight.w700,
                      height: 1.18,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 53, vertical: 15),
                  decoration: ShapeDecoration(
                    color: const Color.fromARGB(30, 37, 111, 93),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'STARTE JETZT',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontFamily: 'League Spartan',
                          fontWeight: FontWeight.w600,
                          height: 1.33,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const SizedBox(
                  width: 326,
                  child: Text(
                    'Jederzeit im App Store kündbar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFB1B4BF),
                      fontSize: 15,
                      fontFamily: 'Onest',
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paywallRow({required String iconpath, required Color color, required Color borderColor, required String title, required String subtitle}) {
    return Container(
      width: double.infinity,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
           
            child: Center(
              child: SvgPicture.asset(
                iconpath,
                width: 40,
                height: 40,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 270,
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF232122),
                      fontSize: 17,
                      fontFamily: 'League Spartan',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(
                  width: 270,
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF232122),
                      fontSize: 15,
                      fontFamily: 'League Spartan',
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
