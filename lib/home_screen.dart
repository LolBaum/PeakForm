import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../util/logging_service.dart';
import 'constants/constants.dart';
import 'screens/camera_screen.dart';
import 'providers/pose_detection_provider.dart';
import 'l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  final String userName;

  const HomeScreen({super.key, this.userName = "User"});

  void _log(String message) {
    try {
      LoggingService.instance.i(message);
    } catch (e) {
      debugPrint('HomeScreen: $message');
    }
  }

  @override
  Widget build(BuildContext context) {
    final translation = AppLocalizations.of(context)!;
    _log('HomeScreen built for user: $userName');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _circularIconButton(Icons.bar_chart, translation),
                    _circularIconButton(Icons.settings, translation),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: AppGaps.gap20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.lightGrey.withAlpha((255 * 0.1).toInt()),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.accent,
                    ),
                    const SizedBox(height: AppGaps.gap12),
                    Text(translation.home_hi_user(userName),
                        style: const TextStyle(
                            fontSize: AppFontSizes.headline,
                            fontWeight: AppFontWeights.extraBold,
                            letterSpacing: 0.5)),
                    const SizedBox(height: AppGaps.gap4),
                    Text(translation.home_progress,
                        style: const TextStyle(
                            fontSize: AppFontSizes.small,
                            fontWeight: AppFontWeights.semiBold,
                            color: AppColors.darkGrey,
                            letterSpacing: 1.5)),
                    Text(translation.home_level,
                        style: const TextStyle(
                            fontSize: AppFontSizes.body,
                            fontWeight: AppFontWeights.bold,
                            color: AppColors.onSurface)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 24.0, left: 16, right: 16, bottom: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.lightGrey.withAlpha((255 * 0.1).toInt()),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Wähle deinen Sport',
                        style: TextStyle(
                            fontSize: AppFontSizes.title,
                            fontWeight: AppFontWeights.bold,
                            color: AppColors.onSurface)),
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _sportTile(
                            context,
                            translation.home_sport_tile_title_tennis,
                            translation.home_sport_tile_subtitle_tennis,
                            null,
                            'assets/tennis.png'),
                        _sportTile(
                            context,
                            translation.home_sport_tile_title_running,
                            translation.home_sport_tile_subtitle_running,
                            '/video',
                            'assets/laufen.jpg'),
                        _sportTile(
                            context,
                            translation.home_sport_tile_title_gym,
                            translation.home_sport_tile_subtitle_gym,
                            '/gym',
                            'assets/gym.jpg'),
                        _sportTile(
                            context,
                            translation.home_sport_tile_title_golf,
                            translation.home_sport_tile_subtitle_golf,
                            null,
                            'assets/golf.jpg'),
                      ],
                    ),
                    Center(
                      child: Column(
                        children: [
                          Text(translation.home_last_recording,
                              style: const TextStyle(
                                  fontSize: AppFontSizes.small,
                                  fontWeight: AppFontWeights.regular,
                                  color: AppColors.darkGrey)),
                          const SizedBox(height: AppGaps.gap6),
                          GestureDetector(
                            onTap: () {
                              _log(
                                  'Aufnehmen button tapped - starting pose detection');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChangeNotifierProvider(
                                    create: (_) => PoseDetectionProvider(),
                                    child: const CameraScreen(),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8),
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: green,
                                      ),
                                      child: const Center(
                                        child: SizedBox(
                                          width: 15,
                                          height: 15,
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(right: 16),
                                    child: Text('Aufnehmen',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circularIconButton(IconData icon, AppLocalizations translation) {
    return GestureDetector(
      onTap: () {
        String buttonName = icon == Icons.bar_chart
            ? translation.home_charts
            : translation.home_settings;
        _log('Circular icon button tapped: $buttonName');
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
            color: AppColors.primary, shape: BoxShape.circle),
        child: Icon(icon, color: AppColors.onPrimary),
      ),
    );
  }

  Widget _sportTile(BuildContext context, String title, String subtitle,
      String? route, String imagePath) {
    return GestureDetector(
      onTap: route != null
          ? () {
              _log('Sport tile tapped: $title (route: $route)');
              Navigator.pushNamed(context, route);
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              AppColors.lightGrey.withAlpha((255 * 0.4).toInt()),
              BlendMode.darken,
            ),
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(0, 255, 255, 255), // very light white top
                      Color.fromARGB(135, 0, 0, 0), // very light black bottom
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppGaps.gap10),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: AppFontWeights.bold,
                        color: AppColors.onPrimary,
                        fontSize: AppFontSizes.title,
                      ),
                    ),
                    const SizedBox(height: AppGaps.gap4),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: AppFontSizes.subtitle,
                        fontWeight: AppFontWeights.regular,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
