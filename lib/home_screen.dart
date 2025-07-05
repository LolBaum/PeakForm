import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness_app/util/logging_service.dart';
import 'constants/constants.dart';
import 'screens/pose_detection_screen.dart';
import 'providers/pose_detection_provider.dart';

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
    _log('HomeScreen built for user: $userName');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _circularIconButton(Icons.bar_chart),
                    _circularIconButton(Icons.settings),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color:
                            AppColors.lightGrey.withAlpha((255 * 0.1).toInt()),
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
                      const SizedBox(height: 12),
                      Text('Hi, $userName!',
                          style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      const Text('FORTSCHRITT',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGrey,
                              letterSpacing: 1.5)),
                      const Text('LVL. 10',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
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
                        color:
                            AppColors.lightGrey.withAlpha((255 * 0.1).toInt()),
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
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface)),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _sportTile(context, 'TENNIS', 'TECHNIK', null,
                              'assets/tennis.png'),
                          _sportTile(
                              context,
                              'LAUFEN',
                              'LAUFÖKONOMIE UND DRILLS',
                              '/video',
                              'assets/laufen.jpg'),
                          _sportTile(context, 'GYM', 'TECHNIK', '/gym',
                              'assets/gym.jpg'),
                          _sportTile(context, 'GOLF', 'AUFSCHLÄGE', null,
                              'assets/golf.jpg'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Column(
                          children: [
                            const Text('LETZTE AUFNAHME: TENNIS',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkGrey)),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () {
                                _log(
                                    'Aufnehmen button tapped - starting pose detection');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ChangeNotifierProvider(
                                      create: (_) => PoseDetectionProvider(),
                                      child: const PoseDetectionScreen(),
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4, right: 8, top: 4, bottom: 4),
                                      child: Container(
                                        width: 35,
                                        height: 35,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.secondary,
                                        ),
                                        child: const Center(
                                          child: SizedBox(
                                            width: 15,
                                            height: 15,
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppColors.onPrimary),
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
                                              color: AppColors.onPrimary)),
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
      ),
    );
  }

  Widget _circularIconButton(IconData icon) {
    return GestureDetector(
      onTap: () {
        String buttonName = icon == Icons.bar_chart ? 'Charts' : 'Settings';
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
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.onPrimary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
