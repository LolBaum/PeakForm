import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Ergebnis',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Image or Animation Placeholder
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Color(0xFF006D42).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(child: Icon(Icons.directions_run, size: 100, color: Color(0xFF006D42))),
              ),
              SizedBox(height: 24),

              // Feedback Section
              Text('Feedback', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),

              // Good Feedback
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Chip(
                      label: Text('GUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      backgroundColor: Color(0xFF006D42),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          feedbackRow(true, 'Aufrechte, nach vorn gerichtete Körperhaltung'),
                          feedbackRow(true, 'Regelmäßige stabile Atmung'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),

              // Bad Feedback
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Chip(
                      label: Text('SCHLECHT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.redAccent,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          feedbackRow(false, 'Arme zu steif oder überschlagen vor dem Körper'),
                          feedbackRow(false, 'Erstes Aufkommen mit der Ferse [00:20min]'),
                          feedbackRow(false, 'Linke Wade zu weit hochgezogen [00:32min]'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Tipps
              Text('Tipps', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              tipRow('Mit Mittelfuß zuerst aufkommen'),
              tipRow('Arme locker mitschwingen lassen'),

              Spacer(),

              // Weiter Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF006D42),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('Weiter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget feedbackRow(bool good, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(good ? Icons.check_circle : Icons.error, color: good ? Color(0xFF006D42) : Colors.red, size: 16),
          SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget tipRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: Colors.black),
          SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
