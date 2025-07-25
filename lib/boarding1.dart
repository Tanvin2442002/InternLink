import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Track and Connect',
      home: const TrackConnectPage(),
    );
  }
}

class TrackConnectPage extends StatelessWidget {
  const TrackConnectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF5D5FEF),
              Color(0xFF7C5DF1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),

              // Top icons (replacing images with icons)
              SizedBox(
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 0,
                      left: 80,
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        radius: 30,
                        child: const Icon(Icons.check, color: Colors.white),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 80,
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        radius: 30,
                        child: const Icon(Icons.message, color: Colors.white),
                      ),
                    ),
                    Positioned(
                      top: 30,
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        radius: 30,
                        child: const Icon(Icons.check_circle, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              // Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'Track and Connect with Ease',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Subtitle
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'Get live updates on your applications\nand message recruiters directly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Page Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(isActive: false),
                  const SizedBox(width: 8),
                  _buildDot(isActive: false),
                  const SizedBox(width: 8),
                  _buildDot(isActive: true),
                ],
              ),

              const SizedBox(height: 50),

              // Get Started button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  // Do something on button press
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Get Started pressed')),
                  );
                },
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    color: Color(0xFF5D5FEF),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot({required bool isActive}) {
    return Container(
      width: isActive ? 10 : 8,
      height: isActive ? 10 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white54,
        shape: BoxShape.circle,
      ),
    );
  }
}
