import 'package:flutter/material.dart';
import 'package:fitness_app/util/logging_service.dart';
import 'constants/constants.dart';

class GymScreen extends StatelessWidget {
  const GymScreen({super.key});

  final List<String> filters = const [
    'Lower Body',
    'Equipment',
    'Abs',
    'Brust',
    'Rücken',
    'Arme',
    'Po'
  ];
  final List<String> exercises = const [
    'Back Squat',
    'Front Squat',
    'Hip Thrusts',
    'Mobilität'
  ];

  @override
  Widget build(BuildContext context) {
    LoggingService.instance.i('GymScreen displayed');

    return Scaffold(
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
                  const SizedBox(height: 16),
                  const Text('MEISTER DEINE',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                  const Text('POSE IM GYM',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 0,
                    children: filters.map((label) {
                      final bool selected =
                          (label == 'Lower Body' || label == 'Equipment');
                      return Chip(
                        label: Text(label,
                            style: TextStyle(
                                color: selected
                                    ? AppColors.onPrimary
                                    : AppColors.darkGrey,
                                fontWeight: FontWeight.bold)),
                        backgroundColor:
                            selected ? AppColors.primary : AppColors.lightGrey,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        shape: const StadiumBorder(),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'VERBESSERN SIE FLEXIBILITÄT, STEIGERN\nSIE MOBILITÄT UND FÖRDERN SIE DAS\nWOHLBEFINDEN.',
                    style: TextStyle(height: 1.4, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'EIN KURS, DER EFFEKTIVES FEEDBACK FÜR\nIHRE KNIEBEUGEN BIETET',
                    style: TextStyle(height: 1.4, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: ElevatedButton(
                            onPressed: () {
                              LoggingService.instance.i(
                                  'User selected exercise: ${exercises[index]}');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 12),
                                Text('${index + 1}',
                                    style: const TextStyle(
                                        color: AppColors.onPrimary,
                                        fontWeight: FontWeight.bold)),
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
                                    exercises[index],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onPrimary,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
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
