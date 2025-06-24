import 'package:flutter/material.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/gym_background.png',
                fit: BoxFit.cover,
                alignment: Alignment.topRight,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Icon(Icons.arrow_back, size: 24),
                      Icon(Icons.star, color: Color(0xFF006D42), size: 28),
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
                    spacing: 8,
                    runSpacing: 8,
                    children: filters.map((label) {
                      final bool selected =
                      (label == 'Lower Body' || label == 'Equipment');
                      return Chip(
                        label: Text(label,
                            style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : Colors.black54,
                                fontWeight: FontWeight.bold)),
                        backgroundColor:
                        selected ? const Color(0xFF006D42) : Colors.grey[300],
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
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF006D42),
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
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(width: 12),
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFFB8FF7B),
                                      shape: BoxShape.circle),
                                  child: const Center(
                                    child: Icon(Icons.play_arrow,
                                        size: 18, color: Color(0xFFDFEAE6)),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    exercises[index],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
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
