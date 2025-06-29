import 'package:flutter/material.dart';
import 'constants/constants.dart';
import 'main.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    logger.i('VideoScreen displayed');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: () {
                    logger.i('User navigated back from video screen');
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back)),
              const SizedBox(height: 16),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF066E47), Color(0xFF5AD689)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                    child: Icon(Icons.play_circle_fill,
                        color: Colors.white.withAlpha((255 * 0.6).toInt()),
                        size: 64)),
              ),
              const SizedBox(height: 16),
              const Text('LAUFEN',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: [
                  _laufenTag('WADEN'),
                  _laufenTag('OBERSCHENKEL'),
                ],
              ),
              const Divider(height: 32, thickness: 1),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(children: [
                    Text('DURCH. ZEIT',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                    Text('20MIN', style: TextStyle(fontWeight: FontWeight.bold))
                  ]),
                  Column(children: [
                    Text('SCHWIERIGKEIT',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                    Text('EINFACH',
                        style: TextStyle(fontWeight: FontWeight.bold))
                  ]),
                  Column(children: [
                    Text('INTENSITÄT',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                    Text('NORMAL',
                        style: TextStyle(fontWeight: FontWeight.bold))
                  ])
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  logger.i('User pressed START button on video screen');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('START',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
              const SizedBox(height: 16),
              const Text('SCHRITT 1 VON 3',
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFF006D42).withAlpha((255 * 0.05).toInt()),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'TRAUST DU DAVON, MÜHELOSER, SCHNELLER UND VERLETZUNGSFREIER ZU LAUFEN? UNSER INNOVATIVER LAUFKURS MACHT ES MÖGLICH! WIR KOMBINIEREN PROFESSIONELLES COACHING MIT DER MODERNSTEN TECHNOLOGIE, UM DEIN LAUFTRAINING AUF EIN VÖLLIG NEUES NIVEAU ZU HEBEN.',
                  style: TextStyle(fontWeight: FontWeight.bold),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: darkGreen,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
