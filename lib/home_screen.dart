import 'package:flutter/material.dart';

import 'constants/constants.dart';

class HomeScreen extends StatelessWidget {
  final String userName;

  const HomeScreen({Key? key, this.userName = "User"}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Color(0xFFB8FF7B),
                      ),
                      const SizedBox(height: 12),
                      Text('Hi, $userName!', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      Text('FORTSCHRITT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[700], letterSpacing: 1.5)),
                      const Text('LVL. 10', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24.0, left: 16, right: 16, bottom: 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Wähle deinen Sport', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _sportTile(context, 'TENNIS', 'TECHNIK', null, 'assets/tennis.png'),
                          _sportTile(context, 'LAUFEN', 'LAUFÖKONOMIE UND DRILLS', '/video', 'assets/laufen.jpg'),
                          _sportTile(context, 'GYM', 'TECHNIK', '/gym', 'assets/gym.jpg'),
                          _sportTile(context, 'GOLF', 'AUFSCHLÄGE', null, 'assets/golf.jpg'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Column(
                          children: [
                            Text('LETZTE AUFNAHME: TENNIS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                decoration: BoxDecoration(
                                  color: darkGreen,
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4, right: 8, top: 4, bottom: 4),
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
                                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(right: 16),
                                      child: Text('Aufnehmen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(color: darkGreen, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget _sportTile(BuildContext context, String title, String subtitle,
      String? route, String imagePath) {
    return GestureDetector(
      onTap: route != null ? () => Navigator.pushNamed(context, route) : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4),
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
                color: Colors.white,
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
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}